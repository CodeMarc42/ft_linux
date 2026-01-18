#!/bin/bash

set -e

echo "Checking optional / extra packages:"
echo "----------------------------------"

check_bin() {
    command -v "$1" >/dev/null 2>&1
}

check_pkg() {
    pkg-config --exists "$1" 2>/dev/null
}

check_lib() {
    ldconfig -p 2>/dev/null | grep -q "$1"
}

check_file() {
    [ -e "$1" ]
}

check() {
    local name="$1"
    local result="NOT FOUND"

    if [ "$2" = "bin" ] && check_bin "$3"; then
        result="INSTALLED"
    elif [ "$2" = "pkg" ] && check_pkg "$3"; then
        result="INSTALLED"
    elif [ "$2" = "lib" ] && check_lib "$3"; then
        result="INSTALLED"
    elif [ "$2" = "file" ] && check_file "$3"; then
        result="INSTALLED"
    fi

    printf "%-12s : %s\n" "$name" "$result"
}

# ---- Checks ----


echo "--Network:"
check "OpenSSL"      bin  openssl
check "Dhcpcd"       bin  dhcpcd
check "Wget"         bin  wget
check "Net-Tools"    bin  arp
check "Curl"         bin  curl
check "Lynx"         bin  lynx

echo "--Security:"
check "OpenSSH"      bin  ssh
check "Make-ca"      bin  make-ca
check "Nettle"       bin  nettle-hash
check "p11-kit"      bin  p11-kit
check "Libxcrypt"    pkg  libxcrypt

echo "--Text Editors:"
check "Nano"         bin  nano

echo "--Virtualization:"
check "Qemu"         bin  qemu

echo "--System Utilities:"
check "Fcron"        bin  fcron
check "Whitch"       bin  which
check "Dbus"         bin  dbus-monitor

echo "--Programming:"
check "Nasm"         bin  nasm
check "Git"          bin  git
check "Cmake"        bin  cmake
check "SWIG"         bin  swig
check "Python"       bin  python3
check "Wheel"        bin  wheel
check "Ninja"        bin  ninja
check "Meson"        bin  meson
check "dtc"          bin  dtc

echo "--Compression:"
check "Lz4"          bin  lz4
check "Zstd"         bin  zstd

echo "--Databases:"
check "Sqlite"       bin  sqlite3
