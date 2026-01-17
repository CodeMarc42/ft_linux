#!/bin/bash
# Checks basic LFS host tools and symlinks

set -e

echo "=== Checking shells ==="
echo -n "Login shell: "; echo $SHELL
echo -n "sh symlink: "; ls -l /bin/sh || echo "/bin/sh not found"

echo
echo "=== Checking awk ==="
ls -l /usr/bin/awk || echo "/usr/bin/awk not found"
awk --version | head -n1 || echo "awk version not found"

echo
echo "=== Checking yacc ==="
ls -l /usr/bin/yacc || echo "/usr/bin/yacc not found"
yacc --version | head -n1 || echo "yacc version not found"

echo
echo "=== Checking essential build tools ==="
TOOLS=("bash" "make" "gcc" "g++" "sed" "grep" "tar" "bzip2" "gzip" "xz" "patch")
for t in "${TOOLS[@]}"; do
    if command -v $t >/dev/null 2>&1; then
        echo "$t: $(command -v $t)"
    else
        echo "$t: NOT FOUND"
    fi
done

echo
echo "=== Host check complete! ==="