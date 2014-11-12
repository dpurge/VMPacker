Import-Module A:\InstallHelpers.psm1

$VMParams = A:\VMParams.ps1
$WorkDir = "C:\Install"

Get-InstallFile `
    -RepositoryURI `
      ("http://{0}:{1}" `
        -F $VMParams.http_ip, $VMParams.http_port_min) `
    -FileList @( `
      "authorized_keys", `
      "dotNetFx45_Full_x86_x64.exe", `
      "Windows6.1-KB2819745-x64-MultiPkg.msu", `
      "setupssh-6.6p1-1(x64).exe", `
      "7z920-x64.msi", `
      #"vmware-tools.exe.tar",
      "oracle-cert.cer"
      ) `
    -OutputDirectory $WorkDir

Enable-WindowsRemoting
Invoke-InitialSystemConfiguration

Write-Host "Installing 7zip ..."
Invoke-WinMSIInstall `
    -Installer "$WorkDir\7z920-x64.msi"

Write-Host "Installing dotNet 4.5 ..."
Invoke-WinExeInstall `
    -Installer "$WorkDir\dotNetFx45_Full_x86_x64.exe"

Write-Host "Applying KB2819745 (installing Powershell 4) ..."
Invoke-WinMSUInstall `
    -Installer "$WorkDir\Windows6.1-KB2819745-x64-MultiPkg.msu"


#if (Test-Path A:\VMInstall.ps1) {
#    Write-Host "Executing VM-specific installation steps ..."
#    A:\VMInstall.ps1
#}

Write-Host "Installing OpenSSH ..."
Install-OpenSSH `
    -Installer "$WorkDir\setupssh-6.6p1-1(x64).exe"

Invoke-VagrantConfiguration -SSHKeyFile "$WorkDir\authorized_keys"

Start-Service "OpenSSHd"
#Restart-Computer