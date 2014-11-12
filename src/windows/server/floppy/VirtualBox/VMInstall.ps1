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
& "C:\Program Files\7-Zip\7z.exe" x C:\Users\vagrant\VBoxGuestAdditions.iso -oC:\Install\virtualbox
Remove-Item C:\Users\vagrant\VBoxGuestAdditions.iso -Force
& "$WorkDir\virtualbox\VBoxWindowsAdditions.exe" /S