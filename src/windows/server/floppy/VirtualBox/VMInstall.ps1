Import-Module A:\InstallHelpers.psm1

$VMParams = A:\VMParams.ps1
$WorkDir = "C:\Install"

$GuestAdditionsIso = "VBoxGuestAdditions_5.0.18.iso"

$InstallFiles = @(
    "oracle-cert.cer",
    "VBoxGuestAdditions_5.0.18.iso")

Get-InstallFile `
    -RepositoryURI `
      ("http://{0}:{1}" `
        -F $VMParams.http_ip, $VMParams.http_port_min) `
    -FileList $InstallFiles `
    -OutputDirectory $WorkDir
    
certutil -addstore -f "TrustedPublisher" $WorkDir\oracle-cert.cer

Mount-DiskImage -ImagePath $WorkDir\$GuestAdditionsIso
$GuestAdditionsIsoVolume = Get-DiskImage $WorkDir\$GuestAdditionsIso | Get-Volume

Start-Process `
    -FilePath ("{0}:\VBoxWindowsAdditions.exe" -F $GuestAdditionsIsoVolume.DriveLetter) `
    -ArgumentList "/S" `
    -Wait

Dismount-DiskImage -ImagePath $WorkDir\$GuestAdditionsIso

Remove-InstallFile -FileList $InstallFiles -OutputDirectory $WorkDir
