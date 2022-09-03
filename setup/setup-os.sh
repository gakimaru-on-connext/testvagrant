#!/bin/sh

echo Setup OS

# Add epel repository
dnf config-manager --set-enabled crb
dnf install https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm

# Install rpm key for remi repository
rpm --import https://rpms.remirepo.net/RPM-GPG-KEY-remi2021
rpm -i https://rpms.remirepo.net//enterprise/remi-release-9.rpm

# Upgrade all packages
dnf -y update

# Install basic packages
dnf -y install expect

# Install language packages
dnf -y install langpacks-ja

# Set hostname
hostnamectl set-hostname testvagrant.localdomain

# Set locale
localectl set-locale LANG=ja_JP.UTF-8

# Set timezone
timedatectl set-timezone Asia/Tokyo

# Set pam limits
# /etc/security/limits.conf を編集して * - nofile 524288 を追加
# 一時的な辺国: ulimit -n 524288

# Create project user & group
useradd test

# Setup project user authorized keys
# /home/test/.ssh/authorized_keys にユーザーのキーを追加

# Add sudoers for project user
# /etc/sudoers.d/test に test ALL=(ALL) NOPASSWD:ALL を追加
