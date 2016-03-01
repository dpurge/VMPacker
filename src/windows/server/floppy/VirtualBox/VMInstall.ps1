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

$DrivesBeforeMount = (Get-Volume).DriveLetter

Mount-DiskImage -ImagePath C:\Users\vagrant\VBoxGuestAdditions.iso
$MountedDrive = Compare $DrivesBeforeMount (Get-Volume).DriveLetter -Passthru
& "${MountedDrive}:\VBoxWindowsAdditions.exe" /S
Dismount-DiskImage -ImagePath C:\Users\vagrant\VBoxGuestAdditions.iso
