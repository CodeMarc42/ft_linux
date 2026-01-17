#!/bin/bash
# Exit on any error
set -e

echo "Activating swap..."
sudo swapon /dev/sdb2

echo "Creating mount points..."
sudo mkdir -pv /mnt/lfs
sudo mkdir -pv /mnt/lfs/boot
sudo mkdir -pv /mnt/lfs/home
sudo mkdir -pv /mnt/lfs/opt

echo "Mounting partitions..."
sudo mount -v /dev/sdb3 /mnt/lfs
sudo mount -v /dev/sdb1 /mnt/lfs/boot
sudo mount -v /dev/sdb4 /mnt/lfs/home
sudo mount -v /dev/sdb5 /mnt/lfs/opt

echo "All partitions mounted successfully!"
df -h /mnt/lfs /mnt/lfs/boot /mnt/lfs/home /mnt/lfs/opt
