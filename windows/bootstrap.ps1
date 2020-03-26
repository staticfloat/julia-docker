<powershell>
Set-ExecutionPolicy Unrestricted

# GitHub became TLS 1.2 only on Feb 22, 2018
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12;
$url = "https://raw.githubusercontent.com/staticfloat/julia-docker/master/windows/provision.ps1"
Invoke-WebRequest -Uri $url -OutFile "provision.ps1" -ErrorAction Stop

# Run the provisioning script
./provision.ps1
</powershell>
<runAsLocalSystem>true</runAsLocalSystem>