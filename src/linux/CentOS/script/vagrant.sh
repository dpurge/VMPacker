#!/usr/bin/env bash

groupadd vagrant -g 900
useradd vagrant -g vagrant -G wheel -u 900
echo "vagrant" | passwd --stdin vagrant

mkdir /home/vagrant/.ssh
wget --no-check-certificate -O /home/vagrant/.ssh/authorized_keys 'https://github.com/mitchellh/vagrant/raw/master/keys/vagrant.pub'
chown -R vagrant /home/vagrant/.ssh
chmod -R go-rwsx /home/vagrant/.ssh

echo "vagrant        ALL=(ALL)       NOPASSWD: ALL" >> /etc/sudoers.d/01vagrant
