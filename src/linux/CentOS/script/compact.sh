#!/usr/bin/env bash

echo "Cleaning yum..."
yum clean all
yum history new
rm --recursive --force /var/lib/yum/yumdb/*
rm --recursive --force /var/lib/yum/history/*
truncate --no-create --size=0 /var/log/yum.log

echo "Fixing selinux file labels..."
fixfiles -R -a restore

echo "Writing zeroes on unused disk space..."
dd if=/dev/zero of=/var/tmp/zeroes bs=1M
rm --force /var/tmp/zeroes

echo "Syncing disk..."
sync
