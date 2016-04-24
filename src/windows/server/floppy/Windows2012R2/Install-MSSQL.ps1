Write-Host "Running MS SQL Server installer ..."
Start-Process `
    -FilePath "D:\Setup.exe" `
    -ArgumentList `
        "/ACTION=Install", `
        "/SQLSVCPASSWORD=V4gr4nt", `
        "/AGTSVCPASSWORD=V4gr4nt", `
        "/ASSVCPASSWORD=V4gr4nt", `
        "/ISSVCPASSWORD=V4gr4nt", `
        "/RSSVCPASSWORD=V4gr4nt", `
        "/SAPWD=V4gr4nt", `
        "/ConfigurationFile=A:\MSSqlServer.ini", `
        "/IAcceptSQLServerLicenseTerms" `
    -Wait

Write-Host "Enabling SQLServer default instance port 1433 ..."
netsh advfirewall firewall add rule name="SQL Server" dir=in action=allow protocol=TCP localport=1433

Write-Host "Enabling Dedicated Admin Connection port 1434 ..."
netsh advfirewall firewall add rule name="SQL Admin Connection" dir=in action=allow protocol=TCP localport=1434

Write-Host "Enabling Conventional SQL Server Service Broker port 4022 ..."
netsh advfirewall firewall add rule name="SQL Service Broker" dir=in action=allow protocol=TCP localport=4022

Write-Host "Enabling Transact SQL/RPC port 135 ..."
netsh advfirewall firewall add rule name="SQL Debugger/RPC" dir=in action=allow protocol=TCP localport=135

Write-Host "Enabling SSAS Default Instance port 2383 ..."
netsh advfirewall firewall add rule name="Analysis Services" dir=in action=allow protocol=TCP localport=2383

Write-Host "Enabling SQL Server Browser Service port 2382 ..."
netsh advfirewall firewall add rule name="SQL Browser" dir=in action=allow protocol=TCP localport=2382
