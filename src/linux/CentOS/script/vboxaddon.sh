#!/usr/bin/env bash

mount -o loop /tmp/VBoxGuestAdditions.iso /media
sh /media/VBoxLinuxAdditions.run
umount /media
rm --force /tmp/VBoxGuestAdditions.iso
