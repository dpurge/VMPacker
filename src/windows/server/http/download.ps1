param(
    $box = "Windows2012R2-mini",
    $iso_repo = "c:/jdp/dat/iso"
)

$md5 = New-Object `
    -TypeName System.Security.Cryptography.MD5CryptoServiceProvider

# M I C R O S O F T  I S O  F I L E S

$Windows2008R2Iso = @{
    filename = "en_windows_server_2008_r2_standard_enterprise_datacenter_and_web_with_sp1_x64_dvd_617601.iso";
    uri = "$iso_repo/en_windows_server_2008_r2_standard_enterprise_datacenter_and_web_with_sp1_x64_dvd_617601.iso";
    checksum = ""}

$MSSQLServer2014 = @{
    filename = "en_sql_server_2014_developer_edition_x64_dvd_3940406.iso";
    uri = "$iso_repo/en_sql_server_2014_developer_edition_x64_dvd_3940406.iso";
    checksum = "1CE007A9F97D6D2E2E93DF14A606D197"}

# C O M M O N  D E P E N D E N C I E S

$VagrantSshKey = @{
    filename = "authorized_keys";
    uri = "https://raw.githubusercontent.com/mitchellh/vagrant/master/keys/vagrant.pub";
    checksum = "B440B5086DD12C3FD8ABB762476B9F40"}

$VBoxGuestAdditions = @{
    filename = "VBoxGuestAdditions_5.0.18.iso";
      uri = "http://download.virtualbox.org/virtualbox/5.0.18/VBoxGuestAdditions_5.0.18.iso";
      checksum = "C7F9DFF1F996630A5EAB9AFFBE27FEBD"}

$PackageManagement = @{
    filename = "PackageManagement_x64.msi";
    uri = "https://download.microsoft.com/download/4/1/A/41A369FA-AA36-4EE9-845B-20BCC1691FC5/PackageManagement_x64.msi";
    checksum = "EB9BFD73B0F07D002910D229170FC022"}

$OpenSsh = @{
    filename = "setupssh-7.2p2-1-v1.exe";
    uri = "http://www.mls-software.com/files/setupssh-7.2p2-1-v1.exe";
    checksum = "E5D08D7CDE2912440B13859F8919B696"}

$Zip7 = @{
    filename = "7z1514-x64.msi";
    uri = "http://7-zip.org/a/7z1514-x64.msi";
    checksum = "B39617FD502261A29E33603760E33F3C"}

# I N S T A L L A T I O N  M E D I A
$media = @{

  "Windows2012R2-mini" = @(
    $VagrantSshKey,
    $VBoxGuestAdditions,
    $OpenSsh,
    $PackageManagement
  )

  "Windows2012R2-mssql" = @(
    $VagrantSshKey,
    $VBoxGuestAdditions,
    $OpenSsh,
    $MSSQLServer2014
  )

}

# D O W N L O A D  F I L E S

if ( -not $media.ContainsKey($box) ) {
    Throw "Unknown box: {0}" -F $box
}

foreach ($item in $media[$box]) {

    [System.IO.FileInfo] $ItemFile = `
        "{0}\{1}" -F $PSScriptRoot, $item.filename
        
    if ($ItemFile.Exists) {
        Write-Host (`
            "`nFile exists: {0}" -F $ItemFile.Name)
    } else {
        Write-Host (`
            "`nFetching file: {0}" -F $ItemFile.Name)
        Invoke-WebRequest $item.uri -OutFile $ItemFile.FullName
    }
    
    Write-Host -n "Checksum: "
    $hash = (Get-FileHash $ItemFile -Algorithm MD5).Hash
    Write-Host -n "   $hash"
    if ($hash -eq $item.checksum) {
        Write-Host " [OK]" -F green
    } else {
        Write-Host " [FAIL]" -F red
    }
}
