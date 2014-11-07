VMPacker
========

[VirtualBox](http://virtualbox.org) 4.3.18 r96516
[Packer](http://packer.io) 0.7.2
[Vagrant](http://vagrantup.com) 1.6.5

Boxes:

* CentOS 7.0 Linux (mini) 64-bit
* Windows 2008 R2 (mini) 64-bit

Package command:

* packer build --var iso_repo=c:/jdp/dat/iso --var box_repo=c:/jdp/dat/vagrant CentOS-7.0-x86_64-mini.json
* packer build --var iso_repo=c:/jdp/dat/iso --var box_repo=c:/jdp/dat/vagrant --only=virtualbox-iso Windows2008R2-mini.json
* packer build --var iso_repo=c:/jdp/dat/iso --var box_repo=c:/jdp/dat/vagrant --only=vmware-iso Windows2008R2-mini.json

Run command:
