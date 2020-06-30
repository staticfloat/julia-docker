Set-ExecutionPolicy Unrestricted

# GitHub became TLS 1.2 only on Feb 22, 2018
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12;

Add-Type -AssemblyName System.IO.Compression.FileSystem
function Unzip($ZipFile, $OutPath) {
    [System.IO.Compression.ZipFile]::ExtractToDirectory($ZipFile, $OutPath)
}


# Install NSSM
function Install-NSSM {
    $url = "http://nssm.cc/ci/nssm-2.24-101-g897c7ad.zip"
    $installer = Join-Path $env:TEMP 'nssm.zip'

    Write-Output "Installing NSSM..."
    Invoke-WebRequest -Uri $url -OutFile $installer -ErrorAction Stop
    Unzip -ZipFile $installer -OutPath "$env:TEMP" -ErrorAction Stop
    Move-Item -Path (Join-Path $env:TEMP 'nssm-2.24-101-g897c7ad\win64\nssm.exe') `
        -Destination "C:\Windows\nssm.exe" `
        -ErrorAction Stop
}
Install-NSSM


# Install Sysinternals
function Install-Sysinternals {
    Write-Output "Installing Sysinternals suite..."
    $url = "https://download.sysinternals.com/files/SysinternalsSuite.zip"
    $installer = Join-Path $env:TEMP 'sysinternals.zip'
    Invoke-WebRequest -Uri "$url" -OutFile "$installer" -ErrorAction Stop
    # Unzip directly into C:\Windows
    Unzip -ZipFile $installer -OutPath "C:\Windows" -ErrorAction Stop
}
Install-Sysinternals


# Install OpenSSH (parameterized on version and listen port, because we need to
# run two different versions on two different ports, for now)
function Install-OpenSSH($version, $listenPort) {
    $url = "https://github.com/PowerShell/Win32-OpenSSH/releases/download/$version/OpenSSH-Win64.zip"

    Write-Output "Installing OpenSSH..."
    $installer = Join-Path $env:TEMP 'OpenSSH-$version.zip'
    $sshdir = Join-Path $env:ProgramFiles "OpenSSH-$version"

    Invoke-WebRequest -Uri $url -OutFile $installer -ErrorAction Stop
    Unzip -ZipFile $installer -OutPath "$env:TEMP" -ErrorAction Stop

    Move-Item -Path (Join-Path $env:TEMP 'OpenSSH-Win64') `
        -Destination "$sshdir" `
        -ErrorAction Stop

    # Create sshd service using NSSM
    $sshdpath = Join-Path "$sshdir" "sshd.exe"
    nssm install "sshd-$version" "$sshdpath" -p $listenPort
    sc.exe privs "sshd-$version" SeAssignPrimaryTokenPrivilege/SeTcbPrivilege/SeBackupPrivilege/SeRestorePrivilege/SeImpersonatePrivilege
    
    New-NetFirewallRule -Name "sshd-$version" `
        -DisplayName "OpenSSH Server (sshd)" `
        -Group "Remote Access" `
        -Description "Allow access via TCP port 22 to the OpenSSH Daemon" `
        -Enabled True `
        -Direction Inbound `
        -Protocol TCP `
        -LocalPort $listenPort `
        -Program (Join-Path $sshdir 'sshd.exe') `
        -Action Allow `
        -ErrorAction Stop

    Write-Output "Configuring SSH..."
    $bashLaunchScript = "C:\autoexec.cmd"
    $cmd = @"
@echo off

if defined SSH_CLIENT (
    :: check if we've got a terminal hooked up; if not, don't run bash.exe
    C:\cygwin\bin\bash.exe -c "if [ -t 1 ]; then exit 1; fi"
    if errorlevel 1 (
        set SSH_CLIENT=
        C:\cygwin\bin\bash.exe --login
        exit
    )
)
"@
    $cmd | Out-File -Encoding ASCII $bashLaunchScript
    $acl = Get-ACL -Path $bashLaunchScript
    $newRule = New-Object System.Security.AccessControl.FileSystemAccessRule("Administrator", "ReadAndExecute", "Allow")
    $acl.AddAccessRule($newRule)
    Set-Acl -Path $bashLaunchScript -AclObject $acl

    New-ItemProperty -Path "HKLM:Software\Microsoft\Command Processor" -Name AutoRun -ErrorAction Stop `
                     -Value "$bashLaunchScript" -PropertyType STRING -Force
}

# Install an older version that works with VS Code on port 2222
# See https://github.com/microsoft/vscode-remote-release/issues/25 for context.
Install-OpenSSH -version "v7.7.2.0p1-Beta" -listenPort 2222

# Install a newer version (that doesn't work with VS Code, but works better with shells) on port 22
Install-OpenSSH -version "v8.1.0.0p1-Beta" -listenPort 22


# Set hostname, this is used to determine which versions of cygwin to install, etc...
$instanceId = (Invoke-RestMethod -Method Get -Uri http://169.254.169.254/latest/meta-data/instance-id)
$instanceTags = Get-EC2Tag -Filter @{ Name="resource-id"; Values=$instanceId }
$hostname = $instanceTags.Where({$_.Key -eq "Name"}).Value
Rename-Computer -NewName $hostname

# Install Cygwin (and add itself to PATH)
function Install-Cygwin {
    Write-Output "Installing Cygwin..."
    $CygDir="c:\cygwin"
    $pkg_list = "git,make,curl,patch,python3,gcc-g++,binutils,gdb,m4,cmake,p7zip,nano,tmux,procps,ccache,time"

    if($hostname.StartsWith("win32")) {
        $arch="x86"
        $pkg_list += ",mingw64-i686-gcc-g++,mingw64-i686-gcc-fortran"
    } else {
        $arch="x86_64"
        $pkg_list += ",mingw64-x86_64-gcc-g++,mingw64-x86_64-gcc-fortran"
    }

    if(!(Test-Path -Path $CygDir -PathType Container)) {
        New-Item -Type Directory -Path $CygDir -Force
    }
    
    Invoke-WebRequest -Uri "http://cygwin.com/setup-$arch.exe" -OutFile "$CygDir\setup-$arch.exe" -ErrorAction Stop    
    Start-Process -wait -FilePath "$CygDir\setup-$arch.exe" -ArgumentList "-q -g -l $CygDir -s http://mirror.cs.vt.edu/pub/cygwin/cygwin/ -R $CygDir -P $pkg_list"

    Invoke-WebRequest -Uri "https://go.microsoft.com/fwlink/p/?LinkID=822845" -OutFile "$CygDir\win10sdksetup.exe" -ErrorAction Stop
    Start-Process -Wait -FilePath "$CygDir\win10sdksetup.exe" -ArgumentList "/quiet"

    [Environment]::SetEnvironmentVariable("Path", "C:\cygwin\bin;" + [Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::Machine), [EnvironmentVariableTarget]::Machine)
}
Install-Cygwin


# Install Python (and add itself to PATH)
function Install-Python {
    param ( $version="3.8.2" )
    $url="https://www.python.org/ftp/python/$version/python-$version-amd64.exe"

    Write-Output "Installing Python $version..."
    $installer = Join-Path $env:TEMP "python-$version-amd64.exe"

    Invoke-WebRequest -Uri $url -OutFile $installer -ErrorAction Stop
    Start-Process -Wait -FilePath "$installer" -ArgumentList "/quiet InstallAllUsers=1 PrependPath=1 Include_test=0"

    # Gotta explicitly update our path
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
}
Install-Python


# Install Julia
function Install-Julia {
    param ( $version="1.4.2" )
    Write-Output "Installing Julia..."

    if($hostname.StartsWith("win32")) {
        $arch="x86"
        $bits = "32"
    } else {
        $arch="x64"
        $bits = "64"
    }

    $majmin = $version.SubString(0, 3)
    $juliaUrl = "https://julialang-s3.julialang.org/bin/winnt/$arch/$majmin/julia-$version-win$bits.exe"
    $installer = Join-Path $env:TEMP "julia-installer.exe"
    $installdir = Join-Path $env:ProgramFiles 'Julia'
    Invoke-WebRequest -Uri "$juliaUrl" -OutFile "$installer" -ErrorAction Stop

    # Run the actual install
    Start-Process -Wait -FilePath "$installer" -ArgumentList "/VERYSILENT /DIR=`"$installdir`""

    # Create shortcut for Julia
    Start-Process -Wait -FilePath "C:\cygwin\bin\bash.exe" -ArgumentList "-c 'ln -s `"$(cygpath `"$installdir`")/bin/julia.exe`" /usr/bin/julia'" 
}
Install-Julia


# Download WireGuard, first, obtaining the wireguard keys from S3
$wgKeysPath = Join-Path $env:TEMP "wireguard.json"
Read-S3Object -BucketName julialangsecure -Key SSH/wireguard.json -File "$wgKeysPath"
$wgKeys = Get-Content -Path "$wgKeysPath" -Encoding ASCII | ConvertFrom-Json
function Install-Wireguard {
    Write-Output "Installing WireGuard..."
    $wgUrl = "https://download.wireguard.com/windows-client/wireguard-amd64-0.0.38.msi"
    $wgInstallFile = Join-Path $env:TEMP "wireguard.msi"
    $wgInstallDir = Join-Path $env:ProgramFiles 'WireGuard'
    Invoke-WebRequest -Uri "$wgUrl" -OutFile "$wgInstallFile" -ErrorAction Stop
    Start-Process -Wait -FilePath "$wgInstallFile" -ArgumentList "/quiet"

    # Only install tunnel service if we find our hostname
    if($wgKeys.PSObject.Properties.Name -contains $hostname) {
        $wgaddr, $wgseckey = $wgKeys.$hostname

        $wgConfigFile = @"
[Interface]
Address = $wgaddr
PrivateKey = $wgseckey

[Peer]
PublicKey = pZq1HmTtHyYP5bToj+hrpVIITbe2oeRlyP19O1D6/QU=
Endpoint = mieli.e.ip.saba.us:37
AllowedIPs = fd37:5040::/64
PersistentKeepalive = 45
"@

        Set-Content -Path $wgInstallDir\wg0.conf -NoNewline -Encoding ASCII -Value $wgConfigFile
        & "$wgInstallDir\wireguard.exe" /installtunnelservice "$wgInstallDir\wg0.conf"

        # Auto-restart wireguard every 8 hours, to help with DNS changes:
        $A = New-ScheduledTaskAction -Execute "C:\cygwin\bin\bash.exe" -Argument "-c 'net stop 'WireGuardTunnel\`$wg0; net start 'WireGuardTunnel\`$wg0'"
        $T = New-ScheduledTaskTrigger -Once -At (Get-Date) -RepetitionInterval (New-TimeSpan -Hours 8)
        Register-ScheduledTask -Action $A -Trigger $T -TaskName "rewg" -Description "Wireguard tunnel auto-restarter"
    }
}
Install-Wireguard


# Install Telegraf
function Install-Telegraf {
    Write-Output "Installing Telegraf..."
    $telegrafUrl = "https://dl.influxdata.com/telegraf/releases/telegraf-1.12.4_windows_amd64.zip"
    $telegrafZip = Join-Path $env:TEMP 'telegraf.zip'
    Invoke-WebRequest -Uri $telegrafUrl -OutFile $telegrafZip -ErrorAction Stop

    $telegrafInstallDir = Join-Path $env:ProgramFiles 'Telegraf'
    Unzip -ZipFile $telegrafZip -OutPath "$env:TEMP" -ErrorAction Stop
    Move-Item -Path (Join-Path $env:TEMP 'telegraf') `
        -Destination $telegrafInstallDir -ErrorAction Stop

    # Spit out telegraf's configuration file
    $telegrafConf = @"
[global_tags]
  project= "julia"
[agent]
  interval = "10s"
  round_interval = true
  metric_batch_size = 1000
  metric_buffer_limit = 10000
  collection_jitter = "0s"
  flush_interval = "60s"
  flush_jitter = "10s"
  precision = ""
  hostname = "$hostname"
  omit_hostname = false
[[outputs.influxdb]]
  urls = ["http://[fd37:5040::dc82:d3f5:c8b7:c381]:8086"]
  content_encoding = "gzip"
[[inputs.cpu]]
  percpu = true
  totalcpu = true
  collect_cpu_time = true
  report_active = true
[[inputs.disk]]
  ignore_fs = ["tmpfs", "devtmpfs", "devfs", "iso9660", "overlay", "aufs", "squashfs"]
[[inputs.diskio]]
[[inputs.kernel]]
[[inputs.mem]]
[[inputs.swap]]
[[inputs.system]]
  fielddrop = ["uptime_format"]
[[inputs.net]]
"@
    Set-Content -Path $telegrafInstallDir\telegraf.conf -NoNewline -Encoding ASCII -Value $telegrafConf

    # Load telegraf config if we actually have a route using wireguard
    if($wgKeys.PSObject.Properties.Name -contains $hostname) {
        & "$telegrafInstallDir\telegraf.exe" --service install
        Start-Service telegraf
    }
}
Install-Telegraf

# Disk initialization
Write-Output "Formatting DATA drive..."
Get-Disk | Where-Object PartitionStyle -eq "RAW" | `
           Initialize-Disk -PartitionStyle GPT -PassThru | `
           New-Volume -FileSystem NTFS -DriveLetter D -FriendlyName 'DATA'


# Install buildbot
function Install-Buildbot {
    Write-Output "Installing Buildbot..."
    if($hostname.StartsWith("win32")) {
        $longArch = "i686"
    } else {
        $longArch = "x86_64"
    }
    $workerIdx = $hostname.SubString($hostname.Length - 1)

    # Install special version of Twisted that is precompiled for windows and python 3.8
    &python -m pip install https://download.lfd.uci.edu/pythonlibs/s2jqpv5t/Twisted-19.10.0-cp38-cp38-win_amd64.whl
    # Now that we've got Twisted, the rest of buildbot should be a cinch
    &python -m pip install pywin32 buildbot-worker

    # Install buildbot workers
    mkdir D:\buildbot
    cd D:\buildbot
    $worker_exe=(Get-Command "buildbot-worker.exe" | Select-Object -ExpandProperty Definition)
    &$worker_exe create-worker --keepalive=100 worker build.julialang.org:9989 win-$longArch-aws_$workerIdx julialang42
    &$worker_exe create-worker --keepalive=100 worker-tabularasa build.julialang.org:9989 tabularasa_win-$longArch-aws_$workerIdx julialang42

    # Initialize services
    nssm install "workerbuild" "$worker_exe" "start --nodaemon ."
    nssm install "workertest" "$worker_exe" "start --nodaemon ."
    nssm set "workerbuild" AppDirectory "D:\buildbot\worker"
    nssm set "workertest" AppDirectory "D:\buildbot\worker-tabularasa"
    nssm set "workerbuild" AppPriority BELOW_NORMAL_PRIORITY_CLASS
    nssm set "workertest" AppPriority BELOW_NORMAL_PRIORITY_CLASS
}
Install-Buildbot


# Install Mono for its codesigning utilities
function Install-Mono() {
    Write-Output "Installing Mono..."
    $url = "https://download.mono-project.com/archive/6.4.0/windows-installer/mono-6.4.0.198-x64-0.msi"
    $installer = Join-Path $env:TEMP 'mono.msi'
    Invoke-WebRequest -Uri "$url" -OutFile "$installer" -ErrorAction Stop
    Start-Process -Wait -FilePath "$installer" -ArgumentList "/quiet"
}
Install-Mono


# Install Firefox, because builtin IE is such a pain
function Install-Firefox {
    Write-Output "Installing Firefox..."
    $url = "https://download.mozilla.org/?product=firefox-latest&os=win64&lang=en-US"
    $installer = Join-Path $env:TEMP 'FirefoxSetup.exe'
    Invoke-WebRequest -Uri "$url" -OutFile "$installer" -ErrorAction Stop
    Start-Process -Wait -FilePath "$installer" -ArgumentList "/S"
}
Install-Firefox


# Set password to the contents of a file we get off of a private S3 bucket
$passwordFile = Join-Path $env:TEMP 'password.txt'
Read-S3Object -BucketName julialangsecure -Key SSH/julia-windows-password.txt -File "$passwordFile"
$password = Get-Content -Path "$passwordFile" -Encoding ASCII
Set-LocalUser -Name "Administrator" -Password  (ConvertTo-SecureString -AsPlainText "$password" -Force) 


# Download `autodump.jl` to D:
$url = "https://raw.githubusercontent.com/JuliaCI/julia-buildbot/master/commands/autodump.jl"
Invoke-WebRequest -Uri "$url" -OutFile "D:\autodump.jl" -ErrorAction Stop


# Disable windows defender
Set-MpPreference -DisableRealtimeMonitoring $true
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender" -Name DisableAntiSpyware -Value 1 -PropertyType DWORD -Force


# Startup OpenSSH/codesigning as SYSTEM
$SYSTEMScript = @'
$sshdir = 'c:\ProgramData\ssh'
$auth_keys = Join-Path $sshdir 'authorized_keys'

If (-Not (Test-Path $sshdir)) {
    New-Item -Path $sshdir -Type Directory
}

& "C:\Program Files\OpenSSH-v8.1.0.0p1-Beta\ssh-keygen.exe" -A

# Download the OpenSSH key associated with this instance
$keyUrl = "http://169.254.169.254/latest/meta-data/public-keys/0/openssh-key"
$keyMaterial = (New-Object System.IO.StreamReader ([System.Net.WebRequest]::Create($keyUrl)).GetResponse().GetResponseStream()).ReadToEnd()

$keyMaterial | Out-File -Append -FilePath $auth_keys -Encoding ASCII

# Ensure access control on authorized_keys meets the requirements
$acl = Get-ACL -Path $auth_keys
$acl.SetAccessRuleProtection($True, $True)
Set-Acl -Path $auth_keys -AclObject $acl

$acl = Get-ACL -Path $auth_keys
$ar = New-Object System.Security.AccessControl.FileSystemAccessRule( `
	"NT Authority\Authenticated Users", "ReadAndExecute", "Allow")
$acl.RemoveAccessRule($ar)
$ar = New-Object System.Security.AccessControl.FileSystemAccessRule( `
	"BUILTIN\Administrators", "FullControl", "Allow")
$acl.RemoveAccessRule($ar)
$ar = New-Object System.Security.AccessControl.FileSystemAccessRule( `
	"BUILTIN\Users", "FullControl", "Allow")
$acl.RemoveAccessRule($ar)
Set-Acl -Path $auth_keys -AclObject $acl

$sshdConfigContent = @"
PasswordAuthentication yes
PubKeyAuthentication yes
PidFile __PROGRAMDATA__/ssh/logs/sshd.pid
AuthorizedKeysFile __PROGRAMDATA__/ssh/authorized_keys
AllowUsers Administrator

Subsystem       sftp    sftp-server.exe
"@

Set-Content -NoNewline -Path C:\ProgramData\ssh\sshd_config -Value $sshdConfigContent

# Download codesigning keys and generate codesigning script
$signHome="C:\cygwin\home\SYSTEM\"
& mkdir $signHome
$codesignScript = @"
#!/bin/bash
# Death to closed-source tools.  Use signcode from Mono:
PASSWORD="Juli@343"
SIGNCODE="/cygdrive/c/Program Files/Mono/bin/signcode"
CERT="$signHome/julia-win-cert.spc"
KEY="$signHome/julia-win-key.pvk"
echo "`${PASSWORD}" | "`${SIGNCODE}" -spc "`${CERT}" -v "`${KEY}" -a sha1 -$ commercial -n "Julia" -t "http://timestamp.verisign.com/scripts/timstamp.dll" -tr 10 "`$1"
"@

# Download codesigning tools
Set-Content -NoNewline -Path "$signHome\sign.sh" -Encoding ASCII -Value $codesignScript
Read-S3Object -BucketName julialangsecure -Key CodeSigning/windows/julia-win-key.pvk -File "$signHome\julia-win-key.pvk"
Read-S3Object -BucketName julialangsecure -Key CodeSigning/windows/julia-win-cert.spc -File "$signHome\julia-win-cert.spc"
'@
$SYSTEMScriptPath = Join-Path $env:TEMP 'setup_SYSTEM.ps1'
$SYSTEMScript | Out-File $SYSTEMScriptPath

# Run the SYSTEM script as, well, SYSTEM.
& psexec /accepteula -i -s Powershell.exe -ExecutionPolicy Bypass -File $SYSTEMScriptPath
if ($LASTEXITCODE -ne 0) {
	throw("Failed to run SYSTEM setup")
}

# Restart to ensure public key authentication works and SSH comes up
Restart-Computer -Force
