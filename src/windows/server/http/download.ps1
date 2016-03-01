param($box = "Windows2012R2-mini")

$iso_repo=c:/jdp/dat/iso
$box_repo=c:/jdp/dat/

$LocalDir = `
    [System.IO.Path]::GetDirectoryName(`
        $myInvocation.MyCommand.Definition)

$md5 = New-Object `
    -TypeName System.Security.Cryptography.MD5CryptoServiceProvider

$media = @{

  "Windows2008R2-mini" = @(
    #@{filename = "Windows2008R2_x64_eval.iso";
    #  uri = "http://download.microsoft.com/download/7/5/E/75EC4E54-5B02-42D6-8879-D8D3A25FBEF7/7601.17514.101119-1850_x64fre_server_eval_en-us-GRMSXEVAL_EN_DVD.iso";
    #  checksum = ""},
    @{filename = "authorized_keys";
      uri = "https://raw.githubusercontent.com/mitchellh/vagrant/master/keys/vagrant.pub";
      checksum = "b440b5086dd12c3fd8abb762476b9f40"},
    @{filename = "dotNetFx45_Full_x86_x64.exe";
      uri = "http://download.microsoft.com/download/b/a/4/ba4a7e71-2906-4b2d-a0e1-80cf16844f5f/dotnetfx45_full_x86_x64.exe";
      checksum = "d02dc8b69a702a47c083278938c4d2f1"},
    @{filename = "Windows6.1-KB2819745-x64-MultiPkg.msu";
      uri = "http://download.microsoft.com/download/3/D/6/3D61D262-8549-4769-A660-230B67E15B25/Windows6.1-KB2819745-x64-MultiPkg.msu";
      checksum = "84497bdd99690c50a8e67db19b0aa2ad"},
    @{filename = "setupssh-6.6p1-1(x64).exe";
      uri = "http://www.mls-software.com/files/setupssh-6.6p1-1(x64).exe";
      checksum = "5fd16a392bb4601da80bb200ecb58e51"},
    @{filename = "7z920-x64.msi";
      uri = "http://sunet.dl.sourceforge.net/project/sevenzip/7-Zip/9.20/7z920-x64.msi";
      checksum = "cac92727c33bec0a79965c61bbb1c82f"}
    #@{filename = "vmware-tools.exe.tar";
    #  uri = "http://softwareupdate.vmware.com/cds/vmw-desktop/ws/10.0.1/1379776/windows/packages/tools-windows-9.6.1.exe.tar";
    #  checksum = "ce1392e127a51c5c44a1015caaffba0d"}
  );

  "Windows2012R2-mini" = @(
    @{filename = "authorized_keys";
      uri = "https://raw.githubusercontent.com/mitchellh/vagrant/master/keys/vagrant.pub";
      checksum = "b440b5086dd12c3fd8abb762476b9f40"},
    @{filename = "setupssh-7.1p2-1.exe";
      uri = "http://www.mls-software.com/files/setupssh-7.1p2-1.exe";
      checksum = "7405ac2b8d90ab45ed1035493504d648"},
    @{filename = "7z1514-x64.msi";
      uri = "http://7-zip.org/a/7z1514-x64.msi";
      checksum = "b39617fd502261a29e33603760e33f3c"},
    @{filename = "VBoxGuestAdditions_5.0.14.iso";
      uri = "http://download.virtualbox.org/virtualbox/5.0.14/VBoxGuestAdditions_5.0.14.iso";
      checksum = "875b430362791acdc5c9340220d39b75"}
  )

}

if ( -not $media.ContainsKey($box) ) {
    Throw "Unknown box: {0}" -F $box
}

foreach ($item in $media[$box]) {

    [System.IO.FileInfo] $ItemFile = `
        "{0}\{1}" -F $LocalDir, $item.filename
        
    if ($ItemFile.Exists) {
        Write-Host (`
            "`nFile exists: {0}" -F $ItemFile.Name)
    } else {
        Write-Host (`
            "`nFetching file: {0}" -F $ItemFile.Name)
        Invoke-WebRequest $item.uri -OutFile $ItemFile.FullName
    }
    
    Write-Host -n "Checksum: "
    $hash = [System.BitConverter]::ToString(`
        $md5.ComputeHash(`
            [System.IO.File]::ReadAllBytes($ItemFile))).ToLower() `
        -replace "-",""
    Write-Host -n "   $hash"
    if ($hash -eq $item.checksum) {
        Write-Host " [OK]" -F green
    } else {
        Write-Host " [FAIL]" -F red
    }
}
