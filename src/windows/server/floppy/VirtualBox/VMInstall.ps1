Import-Module A:\InstallHelpers.psm1

$VMParams = A:\VMParams.ps1
$WorkDir = "C:\Install"

Get-InstallFile `
    -RepositoryURI `
      ("http://{0}:{1}" `
        -F $VMParams.http_ip, $VMParams.http_port_min) `
    -FileList @( `
      "oracle-cert.cer", `
      "VBoxGuestAdditions_5.0.18.iso" `
      ) `
    -OutputDirectory $WorkDir
    
certutil -addstore -f "TrustedPublisher" $WorkDir\oracle-cert.cer

$DrivesBeforeMount = (Get-Volume).DriveLetter
Mount-DiskImage -ImagePath $WorkDir\VBoxGuestAdditions_5.0.18.iso
$MountedDrive = Compare $DrivesBeforeMount (Get-Volume).DriveLetter -Passthru
& "${MountedDrive}:\VBoxWindowsAdditions.exe" /S
Dismount-DiskImage -ImagePath $WorkDir\VBoxGuestAdditions_5.0.18.iso
