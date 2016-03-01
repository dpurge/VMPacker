Import-Module A:\InstallHelpers.psm1

$VMParams = A:\VMParams.ps1
$WorkDir = "C:\Install"

Get-InstallFile `
    -RepositoryURI `
      ("http://{0}:{1}" `
        -F $VMParams.http_ip, $VMParams.http_port_min) `
    -FileList @( `
      "oracle-cert.cer", `
      "VBoxGuestAdditions_5.0.14.iso" `
      ) `
    -OutputDirectory $WorkDir
    
certutil -addstore -f "TrustedPublisher" $WorkDir\oracle-cert.cer

#$DrivesBeforeMount = (Get-Volume).DriveLetter
#Mount-DiskImage -ImagePath C:\Users\vagrant\VBoxGuestAdditions.iso
#$MountedDrive = Compare $DrivesBeforeMount (Get-Volume).DriveLetter -Passthru
#& "${MountedDrive}:\VBoxWindowsAdditions.exe" /S
#Dismount-DiskImage -ImagePath C:\Users\vagrant\VBoxGuestAdditions.iso

# Switch to Mount-DiskImage when Win7/2008R2 no longer needed
& "C:\Program Files\7-Zip\7z.exe" x "$WorkDir\VBoxGuestAdditions_5.0.14.iso" -o"$WorkDir\virtualbox"
Remove-Item "$WorkDir\VBoxGuestAdditions_5.0.14.iso" -Force
& "$WorkDir\virtualbox\VBoxWindowsAdditions.exe" /S