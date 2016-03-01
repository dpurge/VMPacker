Import-Module A:\InstallHelpers.psm1

$VMParams = A:\VMParams.ps1
$WorkDir = "C:\Install"

Get-InstallFile `
    -RepositoryURI `
      ("http://{0}:{1}" `
        -F $VMParams.http_ip, $VMParams.http_port_min) `
    -FileList @( `
      "authorized_keys", `
      "NDP452-KB2901907-x86-x64-AllOS-ENU.exe", `
      "Windows6.1-KB2819745-x64-MultiPkg.msu", `
      "setupssh-7.1p2-1.exe", `
      "7z1514-x64.msi" `
      ) `
    -OutputDirectory $WorkDir

Enable-WindowsRemoting
Invoke-InitialSystemConfiguration

Write-Host "Installing 7zip ..."
Invoke-WinMSIInstall `
    -Installer "$WorkDir\7z1514-x64.msi"

Write-Host "Installing dotNet 4.5.2 ..."
Invoke-WinExeInstall `
    -Installer "$WorkDir\NDP452-KB2901907-x86-x64-AllOS-ENU.exe"

Write-Host "Applying KB2819745 (installing Powershell 4) ..."
Invoke-WinMSUInstall `
    -Installer "$WorkDir\Windows6.1-KB2819745-x64-MultiPkg.msu"

Write-Host "Installing OpenSSH ..."
Install-OpenSSH `
    -Installer "$WorkDir\setupssh-7.1p2-1.exe"

Invoke-VagrantConfiguration -SSHKeyFile "$WorkDir\authorized_keys"

Start-Service "OpenSSHd"
#Restart-Computer