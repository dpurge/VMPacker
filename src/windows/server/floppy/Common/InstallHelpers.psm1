function Enable-WindowsRemoting {                
    Write-Host "Configuring Windows remoting ..." 
    winrm quickconfig -q
    winrm quickconfig -transport:http
    winrm set winrm/config '@{MaxTimeoutms="1800000"}'
    winrm set winrm/config/winrs '@{MaxMemoryPerShellMB="300"}'
    winrm set winrm/config/service '@{AllowUnencrypted="true"}'
    winrm set winrm/config/service/auth '@{Basic="true"}'
    winrm set winrm/config/client/auth '@{Basic="true"}'
    winrm set winrm/config/listener?Address=*+Transport=HTTP '@{Port="5985"}'

    Write-Host "Add firewall rule for WinRM ..." 
    netsh advfirewall firewall set rule group="remote administration" new enable=yes
    Write-Host "Open WinRM port in firewall ..."
    netsh advfirewall firewall add portopening TCP 5985 "Windows Remote Management"

    Write-Host "Stop WinRM service ..." 
    Stop-Service WinRM
    Write-Host "Enable WinRM Autostart ..."
    Set-Service WinRM -StartupType Automatic
    Write-Host "Start Win RM Service ..."
    Start-Service WinRM
}

#=================================================

function Invoke-InitialSystemConfiguration {                
  Write-Host "Show file extensions in Explorer ..." 
  New-Item `
    -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced `
    -Name HideFileExt `
    -Type DWord `
    -Value 0 `
    –Force | Out-Null

  Write-Host "Enable QuickEdit mode ..."
  New-Item `
    -Path HKCU:\Console `
    -Name QuickEdit `
    -Type DWord `
    -Value 1 `
    –Force | Out-Null

  Write-Host "Show Run command in Start Menu ..."
  New-Item `
    -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced `
    -Name Start_ShowRun `
    -Type DWord `
    -Value 1 `
    –Force | Out-Null

  Write-Host "Show Administrative Tools in Start Menu ..."
  New-Item `
    -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced `
    -Name StartMenuAdminTools `
    -Type DWord `
    -Value 1 `
    –Force | Out-Null

  Write-Host "Zero Hibernation File ..."
  New-Item `
    -Path HKLM:\SYSTEM\CurrentControlSet\Control\Power `
    -Name HibernateFileSizePercent `
    -Type DWord `
    -Value 0 `
    –Force | Out-Null

  Write-Host "Disable Hibernation Mode ..."
  New-Item `
    -Path HKLM:\SYSTEM\CurrentControlSet\Control\Power `
    -Name HibernateEnabled `
    -Type DWord `
    -Value 0 `
    –Force | Out-Null

  Write-Host "Enable remote desktop ..."
  New-Item `
    -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server" `
    -Name fDenyTSConnections `
    -Type DWord `
    -Value 0 `
    –Force | Out-Null
  netsh advfirewall firewall add rule name="Open Port 3389" dir=in action=allow protocol=TCP localport=3389

  Write-Host "Disable auto-logon ..."
  New-Item `
    -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" `
    -Name AutoAdminLogon `
    -Type DWord `
    -Value 0 `
    –Force | Out-Null

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
    
    msiexec /qb /i $Installer.FullName
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

Export-ModuleMember –Function @(`
    Get-Command –Module $ExecutionContext.SessionState.Module)