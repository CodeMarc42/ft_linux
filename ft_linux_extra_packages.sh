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


printf "\nNetwork:"
check "OpenSSL"      bin  openssl
check "Dhcpcd"       bin  dhcpcd
check "Wget"         bin  wget
check "Net-Tools"    bin  arp
check "Curl"         bin  curl
check "Lynx"         bin  lynx

printf "\nSecurity:"
check "OpenSSH"      bin  ssh
check "Make-ca"      bin  make-ca
check "Nettle"       bin  nettle-hash
check "p11-kit"      bin  p11-kit
check "Libxcrypt"    pkg  libxcrypt
check "Linux-PAM"    pkg  pwhistory_helper

printf "\nText Editors:"
check "Nano"         bin  nano

printf "\nVirtualization:"
check "Qemu"         bin  qemu

printf "\nSystem Utilities:"
check "Fcron"        bin  fcron
check "Whitch"       bin  which
check "Dbus"         bin  dbus-monitor

printf "\nProgramming:"
check "Nasm"         bin  nasm
check "Git"          bin  git
check "Cmake"        bin  cmake
check "SWIG"         bin  swig
check "Python"       bin  python3
check "Wheel"        bin  wheel
check "Ninja"        bin  ninja
check "Meson"        bin  meson
check "dtc"          bin  dtc

printf "\nCompression:"
check "Lz4"          bin  lz4
check "Zstd"         bin  zstd

printf "\nDatabases:"
check "Sqlite"       bin  sqlite3
