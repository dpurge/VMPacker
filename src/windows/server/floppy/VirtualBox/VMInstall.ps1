Import-Module A:\InstallHelpers.psm1

$VMParams = A:\VMParams.ps1
$WorkDir = "C:\Install"

Get-InstallFile `
    -RepositoryURI `
      ("http://{0}:{1}" `
        -F $VMParams.http_ip, $VMParams.http_port_min) `
    -FileList @( `
      "oracle-cert.cer"
      ) `
    -OutputDirectory $WorkDir
    
certutil -addstore -f "TrustedPublisher" $WorkDir\oracle-cert.cer

[System.IO.FileInfo] $ISO = "C:\Users\vagrant\VBoxGuestAdditions.iso"

if (Get-Command Mount-DiskImage -ErrorAction SilentlyContinue) {
    $DrivesBeforeMount = (Get-Volume).DriveLetter
    Mount-DiskImage -ImagePath $ISO.FullName
    $MountedDrive = Compare $DrivesBeforeMount (Get-Volume).DriveLetter -Passthru
    & "${MountedDrive}:\VBoxWindowsAdditions.exe" /S
    Dismount-DiskImage -ImagePath $ISO.FullName
} else {
	[System.IO.FileInfo] $Zip7 = "C:\Program Files\7-Zip\7z.exe"
    if (-not $Zip7.Exists) {
	    throw "Cannot install guest additions: Mount-DiskImage not available, 7zip not available"
	}
    & $Zip7.FullName x $ISO.FullName -o"$WorkDir\virtualbox"
    & "$WorkDir\virtualbox\VBoxWindowsAdditions.exe" /S
    Remove-Item "$WorkDir\virtualbox" -Recurse -Force
}