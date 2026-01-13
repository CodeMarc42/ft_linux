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

check "Python"       bin  python3
check "Flit-Core"    bin  flit
check "Packaging"    pkg  packaging
check "Wheel"        bin  wheel
check "Setuptools"   pkg  setuptools
check "MarkupSafe"   pkg  markupsafe
check "Jinja2"       pkg  jinja2
check "Sqlite"       bin  sqlite3
check "Meson"        bin  meson
check "Ninja"        bin  ninja
check "Lz4"          bin  lz4
check "Zstd"         bin  zstd
check "OpenSSL"      bin  openssl
check "Libffi"       pkg  libffi
check "Libelf"       pkg  libelf
check "Pcre2"        pkg  libpcre2-8
check "ISL"          pkg  isl
check "Libxcrypt"    pkg  libxcrypt
check "Nano"         bin  nano

echo "----------------------------------"
echo "Done."