Import-Module A:\InstallHelpers.psm1

$VMParams = A:\VMParams.ps1
$WorkDir = "C:\Install"

Get-InstallFile `
    -RepositoryURI `
      ("http://{0}:{1}" `
        -F $VMParams.http_ip, $VMParams.http_port_min) `
    -FileList @( `
      "authorized_keys", `
      "setupssh-7.2p2-1-v1.exe", `
      "7z1514-x64.msi", `
      "oracle-cert.cer", `
      "W2K12-KB3134759-x64.msu" `
      ) `
    -OutputDirectory $WorkDir

Enable-WindowsRemoting
Invoke-InitialSystemConfiguration

Write-Host "Installing 7zip ..."
Invoke-WinMSIInstall `
    -Installer "$WorkDir\7z1514-x64.msi"
    
#Start-Sleep -m 2

Write-Host "Installing KB3134759 ..."
Invoke-WinMSUInstall `
    -Installer "$WorkDir\PackageManagement_x64.msi"

Write-Host "Installing OpenSSH ..."
Install-OpenSSH `
    -Installer "$WorkDir\setupssh-7.2p2-1-v1.exe"

Invoke-VagrantConfiguration -SSHKeyFile "$WorkDir\authorized_keys"

Remove-Item $WorkDir -recurse
Start-Service "OpenSSHd"
#Restart-Computer