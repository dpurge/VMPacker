Import-Module A:\InstallHelpers.psm1

$VMParams = A:\VMParams.ps1
$WorkDir = "C:\Install"

$InstallFiles = @(
    "authorized_keys",
    "oracle-cert.cer",
    "setupssh-7.2p2-1-v1.exe",
    "PackageManagement_x64.msi")

Get-InstallFile `
    -RepositoryURI `
      ("http://{0}:{1}" -F $VMParams.http_ip, $VMParams.http_port_min) `
    -FileList $InstallFiles `
    -OutputDirectory $WorkDir

Enable-WindowsRemoting
Invoke-InitialSystemConfiguration

Install-WindowsFeature -name NET-Framework-Core -source D:\sources\sxs

Invoke-WinMSIInstall -Installer "$WorkDir\PackageManagement_x64.msi"
Enable-WSManCredSSP -Force -Role Server

#Start-Sleep -s 10
#Get-PackageProvider -Name NuGet -ForceBootstrap
#Set-PSRepository -Name PSGallery -InstallationPolicy Trusted

Write-Host "Installing OpenSSH ..."
Install-OpenSSH `
    -Installer "$WorkDir\setupssh-7.2p2-1-v1.exe"

Invoke-VagrantConfiguration -SSHKeyFile "$WorkDir\authorized_keys"

Remove-InstallFile -FileList $InstallFiles -OutputDirectory $WorkDir

Dism.exe /online /Cleanup-Image /StartComponentCleanup /ResetBase
Set-Service wuauserv -startupType Disabled
Stop-Service wuauserv

Start-Service "OpenSSHd"
#Restart-Computer