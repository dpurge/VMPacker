function Enable-WindowsRemoting {                
    Write-Host "Configuring Windows remoting ..." 
    # winrm quickconfig -q
    # winrm quickconfig -transport:http
    winrm set winrm/config '@{MaxTimeoutms="1800000"}'
    winrm set winrm/config/winrs '@{MaxMemoryPerShellMB="300"}'
    winrm set winrm/config/service '@{AllowUnencrypted="true"}'
    winrm set winrm/config/service/auth '@{Basic="true"}'
    winrm set winrm/config/client/auth '@{Basic="true"}'
    winrm set winrm/config/listener?Address=*+Transport=HTTP '@{Port="5985"}'

    Write-Host "Adding * to WinRM trusted hosts ..."
    winrm set winrm/config/client '@{TrustedHosts="*"}'

    Write-Host "Add firewall rule for WinRM ..." 
    netsh advfirewall firewall set rule group="Windows Remote Administration" new enable=yes

    Write-Host "Open WinRM port in firewall ..."
    netsh advfirewall firewall add rule name="Windows Remote Management" dir=in action=allow protocol=TCP localport=5985

    Write-Host "Stop WinRM service ..." 
    Stop-Service WinRM

    Write-Host "Enable WinRM Autostart ..."
    Set-Service WinRM -StartupType Automatic

    Write-Host "Start Win RM Service ..."
    Start-Service WinRM

    Write-Host "Enabling HTTP port 80"
    netsh advfirewall firewall add rule name="HTTP" dir=in action=allow protocol=TCP localport=80

    Write-Host "Enabling SSL port 443
    netsh advfirewall firewall add rule name="SSL" dir=in action=allow protocol=TCP localport=443"
}

#=================================================

function Invoke-InitialSystemConfiguration {
    Push-Location

    Write-Host "Show file extensions in Explorer ..."
    Set-Location HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced
    Set-ItemProperty . HideFileExt "0"

    Write-Host "Enable QuickEdit mode ..."
    Set-Location HKCU:\Console
    Set-ItemProperty . QuickEdit "1"

    Write-Host "Show Administrative Tools in Start Menu ..."
    Set-Location HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced
    Set-ItemProperty . StartMenuAdminTools "1"

    Write-Host "Disable Hibernation ..."
    Set-Location HKLM:\SYSTEM\CurrentControlSet\Control\Power
    Set-ItemProperty . HibernateFileSizePercent "0"
    Set-ItemProperty . HibernateEnabled "0"

    Write-Host "Enable remote desktop ..."
    Set-Location "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server"
    Set-ItemProperty . fDenyTSConnections "0"
    netsh advfirewall firewall add rule name="Open Port 3389" dir=in action=allow protocol=TCP localport=3389

    #Write-Host "Disable auto-logon ..."
    #Set-Location "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
    #Set-ItemProperty . AutoAdminLogon "0"

    Pop-Location
}

#=================================================

function Invoke-VagrantConfiguration {                
    [CmdletBinding()]
    param (
        [Parameter(mandatory=$true)]
        [System.IO.FileInfo] $SSHKeyFile
    )

  Write-Host "Disable password expiration for vagrant user ..."
  wmic useraccount where "name='vagrant'" set PasswordExpires=FALSE
  
  Write-Host "Configure SSH access for vagrant user ..."
  New-Item -ItemType Directory -Force -Path "C:\Users\vagrant\.ssh"
  
  C:\Windows\System32\icacls.exe "C:\Users\vagrant" /grant "vagrant:(OI)(CI)F"
  C:\Windows\System32\icacls.exe "C:\Program Files\OpenSSH\bin" /grant "vagrant:(OI)RX"
  C:\Windows\System32\icacls.exe "C:\Program Files\OpenSSH\usr\sbin" /grant "vagrant:(OI)RX"
  
  C:\Windows\System32\icacls.exe "C:\Windows\Temp" /grant "vagrant:(OI)(CI)F"
  
  @(
      "TEMP=C:\Windows\Temp",
      "ProgramFiles(x86)=C:\Program Files (x86)",
      "ProgramW6432=C:\Program Files",
      "CommonProgramFiles(x86)=C:\Program Files (x86)\Common Files",
      "CommonProgramW6432=C:\Program Files\Common Files"
  ) -join "`r`n" | Set-Content C:\Users\vagrant\.ssh\environment
  
  Copy-Item `
      -Path $SSHKeyFile.FullName `
      -Destination C:\Users\vagrant\.ssh\authorized_keys
}

#=================================================

function Get-InstallFile {                
    [CmdletBinding()]
    param (
        [Parameter(mandatory=$true)]
        [string] $RepositoryURI,
        [Parameter(mandatory=$true)]
        [string[]] $FileList,
        [Parameter(mandatory=$true)]
        [System.IO.DirectoryInfo] $OutputDirectory
    )
    if ( -not $OutputDirectory.Exists) {
        Write-Host (`
            "Creating directory {0} ..." `
                -F $OutputDirectory.FullName)
        $OutputDirectory.Create()
    }
    $WebClient = New-Object System.Net.WebClient
    foreach ($item in $FileList) {
        $OutItem = "{0}\$item" -F $OutputDirectory.FullName
        Write-Host "Downloading $OutItem ..."
        $WebClient.DownloadFile("$RepositoryURI/$item", $OutItem)
    }
}

#=================================================

function Remove-InstallFile {

    [CmdletBinding()]
    param (
        [Parameter(mandatory=$true)]
        [string[]] $FileList,
        [Parameter(mandatory=$true)]
        [System.IO.DirectoryInfo] $OutputDirectory
    )

    foreach ($item in $FileList) {
        $OutItem = "{0}\$item" -F $OutputDirectory.FullName
        Write-Host "Removing $OutItem ..."
        Remove-Item $OutItem -Force
    }
}

#=================================================

function Invoke-WinExeInstall {                
    [CmdletBinding()]
    param (
        [Parameter(mandatory=$true)]
        [System.IO.FileInfo] $Installer
    )
    
    Start-Process `
        -FilePath $Installer.FullName `
        -ArgumentList "/passive","/norestart" `
        -Wait 
}

#=================================================

function Invoke-WinMSUInstall {                
    [CmdletBinding()]
    param (
        [Parameter(mandatory=$true)]
        [System.IO.FileInfo] $Installer
    )
    
    Start-Process `
        -FilePath wusa.exe `
        -ArgumentList $Installer.FullName,"/quiet","/norestart" `
        -Wait
}

#=================================================

function Invoke-WinMSIInstall {                
    [CmdletBinding()]
    param (
        [Parameter(mandatory=$true)]
        [System.IO.FileInfo] $Installer
    )
    
    msiexec /qn /i $Installer.FullName
}

#=================================================

function Install-OpenSSH {                
    [CmdletBinding()]
    param (
        [Parameter(mandatory=$true)]
        [System.IO.FileInfo] $Installer
    )
    
    Start-Process $Installer.FullName `
        "/S /port=22 /privsep=1 /password=D@rj33l1ng" `
        -NoNewWindow `
        -Wait
    Stop-Service "OpenSSHd" -Force
    
    $EtcPasswd = Get-Content "C:\Program Files\OpenSSH\etc\passwd" `
        | %{ $_ -replace '/home/(\w+)', '/cygdrive/c/Users/$1' } `
        | %{ $_ -replace '/bin/bash', '/bin/sh' }
    Set-Content 'C:\Program Files\OpenSSH\etc\passwd' $EtcPasswd
        
    $SSHConfig = Get-Content "C:\Program Files\OpenSSH\etc\sshd_config" `
        | %{ $_ -replace 'StrictModes yes', 'StrictModes no'} `
        | %{ $_ -replace '#PubkeyAuthentication yes', 'PubkeyAuthentication yes'} `
        | %{ $_ -replace '#PermitUserEnvironment no', 'PermitUserEnvironment yes'} `
        | %{ $_ -replace '#UseDNS yes', 'UseDNS no'} `
        | %{ $_ -replace 'Banner /etc/banner.txt', '#Banner /etc/banner.txt'}
    Set-Content "C:\Program Files\OpenSSH\etc\sshd_config" $SSHConfig
        
    Remove-Item -Recurse -Force -ErrorAction SilentlyContinue "C:\Program Files\OpenSSH\tmp"
    
    C:\Program` Files\OpenSSH\bin\junction.exe /accepteula "C:\Program Files\OpenSSH\tmp" "C:\Windows\Temp"
    
    netsh advfirewall firewall add rule name="SSHD" dir=in action=allow service=OpenSSHd enable=yes
    
    netsh advfirewall firewall add rule name="SSHD" dir=in action=allow program="C:\Program Files\OpenSSH\usr\sbin\sshd.exe" enable=yes
    
    netsh advfirewall firewall add rule name="ssh" dir=in action=allow protocol=TCP localport=22
}

#=================================================

Export-ModuleMember -Function @(`
    Get-Command -Module $ExecutionContext.SessionState.Module)