#!/bin/bash

set -e

GREEN="\e[32m"
RED="\e[31m"
RESET="\e[0m"

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
    local result="${RED}NOT FOUND${RESET}"

    if [ "$2" = "bin" ] && check_bin "$3"; then
        result="${GREEN}INSTALLED${RESET}"
    elif [ "$2" = "pkg" ] && check_pkg "$3"; then
        result="${GREEN}INSTALLED${RESET}"
    elif [ "$2" = "lib" ] && check_lib "$3"; then
        result="${GREEN}INSTALLED${RESET}"
    elif [ "$2" = "file" ] && check_file "$3"; then
        result="${GREEN}INSTALLED${RESET}"
    fi

    printf "%-12s : %b\n" "$name" "$result"
}

# ---- Checks ----


printf "\nNetwork:\n"
check "OpenSSL"      bin  openssl
check "Dhcpcd"       bin  dhcpcd
check "Wget"         bin  wget
check "Net-Tools"    bin  arp
check "Curl"         bin  curl
check "Lynx"         bin  lynx

printf "\nSecurity:\n"
check "OpenSSH"      bin  ssh
check "Make-ca"      bin  make-ca
check "Nettle"       bin  nettle-hash
check "p11-kit"      bin  p11-kit
check "Libxcrypt"    pkg  libxcrypt
check "Linux-PAM"    bin  pwhistory_helper

printf "\nText Editors:\n"
check "Nano"         bin  nano

printf "\nVirtualization:\n"
check "Qemu"         bin  qemu

printf "\nSystem Utilities:\n"
check "Fcron"        bin  fcron
check "Whitch"       bin  which
check "Dbus"         bin  dbus-monitor

printf "\nProgramming:\n"
check "Nasm"         bin  nasm
check "Git"          bin  git
check "Cmake"        bin  cmake
check "SWIG"         bin  swig
check "Python"       bin  python3
check "Wheel"        bin  wheel
check "Ninja"        bin  ninja
check "Meson"        bin  meson
check "dtc"          bin  dtc

printf "\Graphical Environments:\n"
check "Xorg Applications" bin  xauth
check "Xorg Server"  bin  gtf
check "twm"          bin  twm
check "xterm"        bin  xterm
check "xclock"       bin  xclock
check "xinit"        bin  xinit

printf "\nCompression:\n"
check "Lz4"          bin  lz4
check "Zstd"         bin  zstd

printf "\nDatabases:\n"
check "Sqlite"       bin  sqlite3
