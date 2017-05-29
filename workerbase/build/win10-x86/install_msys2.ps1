# Install Msys2 and most of a toolchain
function Install-Msys2 {
    param ( $arch="i686" )

    if( $arch -eq "x86_64" ) {
        $bits = "64"
    } else {
        $bits = "32"
    }

    # change the date in the following for future msys2 releases
    $msys2tarball = "msys2-base-$arch-20161025.tar"
    $msyspath = "C:\msys$bits"

    # install chocolatey and cmake
    Write-Verbose "Installing Chocolatey from https://chocolatey.org/install.ps1"
    iex ((new-object net.webclient).DownloadString("https://chocolatey.org/install.ps1"))
    choco install -y cmake.portable

    # pacman is picky, reinstall msys2 from scratch
    foreach ($dir in @("etc", "usr", "var", "mingw32")) {
      if (Test-Path "$msyspath\$dir") {
        rm -Recurse -Force $msyspath\$dir
      }
    }
    mkdir -Force $msyspath | Out-Null

    Write-Verbose "Installing 7za from https://chocolatey.org/7za.exe"
    (new-object net.webclient).DownloadFile(
      "https://chocolatey.org/7za.exe",
      "$msyspath\7za.exe")

    Write-Verbose "Installing msys2 from http://sourceforge.net/projects/msys2/files/Base/$arch/$msys2tarball.xz"
    (new-object net.webclient).DownloadFile(
      "http://sourceforge.net/projects/msys2/files/Base/$arch/$msys2tarball.xz",
      "$msyspath\$msys2tarball.xz")

    cd C:\
    &"$msyspath\7za.exe" x -y "$msyspath\$msys2tarball.xz"
    &"$msyspath\7za.exe" x -y "$msys2tarball" | Out-Null

    Write-Verbose "Installing bash, pacman, pacman-mirrors and msys2-runtime"
    &$msyspath\usr\bin\sh -lc "pacman --noconfirm --force --needed -Sy bash pacman pacman-mirrors msys2-runtime"

    $pkg_list = "diffutils git curl vim m4 make patch tar p7zip openssh cygrunsrv mingw-w64-$arch-editrights procps"
    Write-Verbose "Installing $pkg_list"
    &$msyspath\usr\bin\sh -lc "pacman --noconfirm -Syu && pacman --noconfirm -S $pkg_list"

    Write-Verbose "Rebasing MSYS2"
    &$msyspath\autorebase.bat

    # Let's install python
    Write-Verbose "Installing python from chocolatey"
    choco install -y python2
}

$VerbosePreference = "Continue"

# Then, install Msys2 as either 64-bit or 32-bit
Install-Msys2 -arch "$env:WIN_ARCH"
