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
      "7z1514-x64.msi", `
	  "en_sql_server_2008_r2_developer_x86_x64_ia64_dvd_522665.iso", `
	  "en_visual_studio_premium_2013_with_update_5_x86_dvd_6815742.iso", `
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

Write-Host "Installing Microsoft SQL Server ..."
& "C:\Program Files\7-Zip\7z.exe" x "$WorkDir\en_sql_server_2008_r2_developer_x86_x64_ia64_dvd_522665.iso" -o"$WorkDir\MSSQLSrv"
& "$WorkDir\MSSQLSrv\Setup.exe" /ConfigurationFile="A:\MSSQLServerConfigurationFile.ini"
Remove-Item "$WorkDir\MSSQLSrv" -Recurse -Force
Remove-Item "$WorkDir\en_sql_server_2008_r2_developer_x86_x64_ia64_dvd_522665.iso" -Force

# vs_Product.exe /adminfile xxx.ini /Q /S /NoWeb /NoRefresh
#vs_professional.exe /Q /S /LOG %SYSTEMROOT%\TEMP\VS_2013_U3.log /NoWeb /NoRefresh /Full /ProductKey XXXX-XXXX-XXXX-XXX

Write-Host "Installing OpenSSH ..."
Install-OpenSSH `
    -Installer "$WorkDir\setupssh-7.1p2-1.exe"

Invoke-VagrantConfiguration -SSHKeyFile "$WorkDir\authorized_keys"

Start-Service "OpenSSHd"