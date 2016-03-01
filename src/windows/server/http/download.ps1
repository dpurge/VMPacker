param(
    $box = "Windows7-mini",
    $iso_repo = "c:/jdp/dat/iso"
)

$md5 = New-Object `
    -TypeName System.Security.Cryptography.MD5CryptoServiceProvider

# M I C R O S O F T  I S O  F I L E S

$Windows7Iso = @{
    filename = "SW_DVD5_Win_Pro_7w_SP1_64BIT_English_-2_MLF_X17-59279.ISO";
    uri = "$iso_repo/SW_DVD5_Win_Pro_7w_SP1_64BIT_English_-2_MLF_X17-59279.ISO";
    checksum = "3C394E66C208CFD641B976DE10FE90B5"}

$Windows2008R2Iso = @{
    filename = "en_windows_server_2008_r2_standard_enterprise_datacenter_and_web_with_sp1_x64_dvd_617601.iso";
    uri = "$iso_repo/en_windows_server_2008_r2_standard_enterprise_datacenter_and_web_with_sp1_x64_dvd_617601.iso";
    checksum = ""}

$MSSQLServer2008R2 = @{
    filename = "en_sql_server_2008_r2_developer_x86_x64_ia64_dvd_522665.iso";
    uri = "$iso_repo/en_sql_server_2008_r2_developer_x86_x64_ia64_dvd_522665.iso";
    checksum = ""}

# C O M M O N  D E P E N D E N C I E S

$VagrantSshKey = @{
    filename = "authorized_keys";
    uri = "https://raw.githubusercontent.com/mitchellh/vagrant/master/keys/vagrant.pub";
    checksum = "B440B5086DD12C3FD8ABB762476B9F40"}

$VBoxGuestAdditions = @{
    filename = "VBoxGuestAdditions_5.0.14.iso";
      uri = "http://download.virtualbox.org/virtualbox/5.0.14/VBoxGuestAdditions_5.0.14.iso";
      checksum = "875B430362791ACDC5C9340220D39B75"}

$OpenSsh = @{
    filename = "setupssh-7.1p2-1.exe";
    uri = "http://www.mls-software.com/files/setupssh-7.1p2-1.exe";
    checksum = "7405ac2b8d90ab45ed1035493504d648"}

$Zip7 = @{
    filename = "7z1514-x64.msi";
    uri = "http://7-zip.org/a/7z1514-x64.msi";
    checksum = "B39617FD502261A29E33603760E33F3C"}

$DotNet452 = @{
    filename = "NDP452-KB2901907-x86-x64-AllOS-ENU.exe";
    uri = "https://download.microsoft.com/download/E/2/1/E21644B5-2DF2-47C2-91BD-63C560427900/NDP452-KB2901907-x86-x64-AllOS-ENU.exe";
    checksum = "EE01FC4110C73A8E5EFC7CABDA0F5FF7"}

$KB2819745 = @{
    filename = "Windows6.1-KB2819745-x64-MultiPkg.msu";
    uri = "http://download.microsoft.com/download/3/D/6/3D61D262-8549-4769-A660-230B67E15B25/Windows6.1-KB2819745-x64-MultiPkg.msu";
    checksum = "84497bdd99690c50a8e67db19b0aa2ad"}

# I N S T A L L A T I O N  M E D I A
$media = @{

  "Windows7-mini" = @(
    $Windows7Iso,
    $VBoxGuestAdditions,
    $VagrantSshKey,
    $DotNet452,
    $KB2819745,
    $OpenSsh,
    $Zip7
  );

  "Windows2008R2-mini" = @(
    $Windows2008R2Iso,
    $VBoxGuestAdditions,
    $VagrantSshKey,
    $DotNet452,
    $KB2819745,
    $OpenSsh,
    $Zip7
  );

  "Windows2012R2-mini" = @(
    $VagrantSshKey,
    $VBoxGuestAdditions,
    $OpenSsh,
    $Zip7
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
