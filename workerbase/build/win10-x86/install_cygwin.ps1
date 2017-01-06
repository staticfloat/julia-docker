function Install-Cygwin {
    param ( $CygDir="c:\cygwin", $arch="x86")

    Write-Verbose "Installing Cygwin and Windows 10 SDK for $arch"
    if(!(Test-Path -Path $CygDir -PathType Container)) {
        Write-Verbose "Creating directory $CygDir"
        New-Item -Type Directory -Path $CygDir -Force
    }
    Write-Verbose "Downloading http://cygwin.com/setup-$arch.exe"
    $client = new-object System.Net.WebClient
    $client.DownloadFile("http://cygwin.com/setup-$arch.exe", "$CygDir\setup-$arch.exe" )

    $pkg_list = "git,make,curl,patch,python,gcc-g++,m4,cmake,p7zip,nano,tmux,procps"
    if( $arch -eq "x86" ) {
        $pkg_list += ",mingw64-i686-gcc-g++,mingw64-i686-gcc-fortran"
    } else {
        $pkg_list += ",mingw64-x86_64-gcc-g++,mingw64-x86_64-gcc-fortran"
    }

    Write-Verbose "Installing Cygwin and $pkg_list"
    Start-Process -wait -FilePath "$CygDir\setup-$arch.exe" -ArgumentList "-q -g -l $CygDir -s http://mirror.mit.edu/cygwin/ -R c:\cygwin -P $pkg_list"

    Write-Verbose "Downloading and running Windows 10 SDK"
    $client.DownloadFile( "https://go.microsoft.com/fwlink/p/?LinkID=822845", "$CygDir\sdksetup.exe" )
    Start-Process -FilePath "$CygDir\sdksetup.exe"
}

$VerbosePreference = "Continue"
Install-Cygwin -arch "$env:CYGWIN_ARCH"
