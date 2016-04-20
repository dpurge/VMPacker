VMPacker
========

[VirtualBox](http://virtualbox.org) 5.0.18-106667
[Packer](http://packer.io) 0.10.0
[Vagrant](http://vagrantup.com) 1.8.1

Boxes:

* CentOS 7.0 Linux (mini)
* Windows 2012 R2 (mini)

Current precise versions to be checked in the installation scripts.
English 64-bit versions of the applications used whenever available.

Get installation files:

* .\src\windows\server\http\download.ps1 -box Windows2012R2-mini

When box requires it, manually copy ISO files to the http directory:

* en_sql_server_2014_developer_edition_x64_dvd_3940406.iso
* en_visual_studio_team_foundation_server_2015_x86_x64_dvd_6909713.iso

For windows, remeber to set the key in the Autounattend file.

Package command:

* packer build --var iso_repo=c:/jdp/dat/iso --var box_repo=c:/jdp/dat/vagrant CentOS-7.0-x86_64-mini.json
* packer build --var iso_repo=c:/jdp/dat/iso --var box_repo=c:/jdp/dat/vagrant --only=virtualbox-iso Windows2012R2-mini.json


Run the box
---

* vagrant box add --name Windows2012R2-mini file:///C:/jdp/dat/vagrant/Windows2012R2-mini-virtualbox.box
* vagrant init Windows2012R2-mini
* vagrant up
* vagrant rdp
* vagrant halt
* vagrant status
* vagrant destroy --force
* vagrant box list
* vagrant box remove Windows2012R2-mini
