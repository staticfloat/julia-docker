function Disable-InternetExplorerESC {
    $AdminKey = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}"
    $UserKey = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}"
    Set-ItemProperty -Path $AdminKey -Name "IsInstalled" -Value 0
    Set-ItemProperty -Path $UserKey -Name "IsInstalled" -Value 0
    Stop-Process -Name Explorer
    Write-Verbose "IE Enhanced Security Configuration (ESC) has been disabled."
}


function EnableAutomaticUpdates {
    $AUSettings = (New-Object -com "Microsoft.Update.AutoUpdate").Settings
    $AUSettings.NotificationLevel = 4
    $AUSettings.Save()
}


function Install-Cygwin {
    param($CygDir="c:\cygwin", $arch="x86")
    if( $arch -eq "x86" ) {
        $cygwin_url = "https://cygwin.com/setup-x86.exe"
    } else {
        $cygwin_url = "https://cygwin.com/setup-x86_64.exe"
    }

    if(!(Test-Path -Path $CygDir -PathType Container)) {
        Write-Verbose "Creating directory $CygDir"
        New-Item -Type Directory -Path $CygDir -Force
    }
    Write-Verbose "Downloading $cygwin_url"
    $client = new-object System.Net.WebClient
    $client.DownloadFile($cygwin_url, "$CygDir\setup.exe")

    $pkg_list = "git,make,curl,patch,python,python-devel,gcc-g++,m4,cmake,p7zip,nano,tmux,cron,procps"
    if( $arch -eq "x86" ) {
        $pkg_list += ",mingw64-i686-gcc-g++,mingw64-i686-gcc-fortran"
    } else {
        $pkg_list += ",mingw64-x86_64-gcc-g++,mingw64-x86_64-gcc-fortran"
    }

    Write-Verbose "Installing Cygwin and $pkg_list"
    Start-Process -wait -FilePath "$CygDir\setup.exe" -ArgumentList "-q -g -l $CygDir -s http://mirror.mit.edu/cygwin/ -R $CygDir -P $pkg_list"
    $env:Path = $env:Path + ";$CygDir\bin"
}

function Install-WinSDK {
    param($arch="x86")
    Write-Verbose "Installing Windows SDK..."
    $client = new-object System.Net.WebClient
    $client.DownloadFile( "https://download.microsoft.com/download/3/6/3/36301F10-B142-46FA-BE8C-728ECFD62EA5/windowssdk/winsdksetup.exe", "C:\Users\vagrant\winsdksetup.exe" )
    Start-Process -FilePath "C:\Users\vagrant\winsdksetup.exe"
    $env:Path = $env:Path + ";C:\Program Files(x86)/Windows Kits/10/bin/${arch}"
}

function Install-Buildbot {
    param($buildworker_name="win6_3-x86")
    Write-Verbose "Installing pip..."
    bash --login -c 'python -m ensurepip'

    Write-Verbose "Installing buildbot..."
    bash C:\Users\vagrant\buildbot_setup.sh $buildworker_name
}

function Update-Path {
    Write-Verbose "Persisting path..."
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v Path /t REG_SZ /f /d "$env:Path"
}


$VerbosePreference = "Continue"
Disable-InternetExplorerESC
Install-Cygwin -arch $args[0]
Install-WinSDK -arch $args[0]
Install-Buildbot -buildworker_name $args[1]
Update-Path
EnableAutomaticUpdates
