#!/bin/bash

echo "========================================="
echo "LFS Project Requirement Verification"
echo "========================================="

MYLOGIN="marza-ga"

LOGIN=$(cat /etc/hostname 2>/dev/null || echo "NOT_SET")
KERNEL_VERSION=$(uname -r)
KERNEL_NAME=$(uname -s)
ARCH=$(uname -m)

echo
echo "1. Linux kernel check (uname -s):"
if [ "$KERNEL_NAME" = "Linux" ]; then
    echo "   ✅ PASS: Kernel is Linux"
else
    echo "   ❌ FAIL: Kernel is not Linux ($KERNEL_NAME)"
fi

echo
echo "2. Kernel version >= 4.0:"
MAJOR_VERSION=$(echo "$KERNEL_VERSION" | cut -d. -f1)
if [ "$MAJOR_VERSION" -ge 4 ]; then
    echo "   ✅ PASS: Kernel version $KERNEL_VERSION"
else
    echo "   ❌ FAIL: Kernel version too old ($KERNEL_VERSION)"
fi

echo
echo "3. Kernel sources in /usr/src/kernel-<version>:"
if [ -d "/usr/src/kernel-$KERNEL_VERSION" ]; then
    echo "   ✅ PASS: /usr/src/kernel-$KERNEL_VERSION exists"
else
    echo "   ❌ FAIL: /usr/src/kernel-$KERNEL_VERSION missing"
fi

echo
echo "4. Required partitions (/ , /boot , swap):"
lsblk -f | grep -E " /$| /boot$|\[SWAP\]" || echo "   ❌ FAIL: Missing required partitions"

echo
echo "5. Kernel module loader (udev):"
if command -v udevadm >/dev/null 2>&1; then
    echo "   ✅ PASS: udev installed ($(udevadm --version))"
else
    echo "   ❌ FAIL: udev not found"
fi

echo
echo "6. Kernel version contains student login:"
if [[ "$KERNEL_VERSION" == *"$MYLOGIN"* ]]; then
    echo "   ✅ PASS: Kernel version contains '$MYLOGIN'"
else
    echo "   ❌ FAIL: Kernel version does not contain '$MYLOGIN'"
fi

echo
echo "7. Hostname equals student login:"
if [ "$LOGIN" = "$MYLOGIN" ]; then
    echo "   ✅ PASS: Hostname is '$LOGIN'"
else
    echo "   ❌ FAIL: Hostname is '$LOGIN' (expected '$MYLOGIN')"
fi

echo
echo "8. Architecture (32-bit or 64-bit):"
case "$ARCH" in
    i686|i386)
        echo "   ✅ PASS: 32-bit system ($ARCH)"
        ;;
    x86_64)
        echo "   ✅ PASS: 64-bit system ($ARCH)"
        ;;
    *)
        echo "   ⚠️  WARN: Unknown architecture ($ARCH)"
        ;;
esac

echo
echo "9. Init / service manager (SysV or systemd):"
if [ -d /run/systemd/system ]; then
    echo "   ✅ PASS: systemd in use"
elif [ -x /sbin/init ]; then
    echo "   ✅ PASS: SysV init present"
else
    echo "   ❌ FAIL: No init system detected"
fi

echo
echo "10. Bootloader (GRUB):"
if [ -f /boot/grub/grub.cfg ]; then
    echo "   ✅ PASS: GRUB configuration found"
else
    echo "   ❌ FAIL: GRUB configuration missing"
fi

echo
echo "11. Kernel image name in /boot:"
KERNEL_IMG=$(ls /boot/vmlinuz-* 2>/dev/null | grep "$MYLOGIN")
if [ -n "$KERNEL_IMG" ]; then
    echo "   ✅ PASS: Found kernel image:"
    echo "       $(basename "$KERNEL_IMG")"
else
    echo "   ❌ FAIL: Kernel image naming does not match requirement"
fi

echo
echo "========================================="
echo "Verification Complete"
echo "========================================="