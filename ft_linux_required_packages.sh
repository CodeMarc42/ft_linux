#!/bin/bash

# ============================================
# LFS Package Installation Verification Script
# ============================================

TOTAL=0
SUCCESS=0

# Color codes
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
NC='\033[0m' # No Color

# ==================== Functions ====================
function check_package {
    local pkg="$1"
    local check_type="$2"
    
    printf "%-25s" "$pkg"
    TOTAL=$((TOTAL + 1))
    
    case "$check_type" in
        "lib")
            # Check for library files
            if find /usr/lib /lib -name "*${pkg,,}*" 2>/dev/null | grep -q "."; then
                printf "${GREEN}✓ Installed${NC}\n"; SUCCESS=$((SUCCESS + 1))
            else printf "${RED}✗ Missing${NC}\n"; fi
            ;;
            
        "bin")
            # Check for binary/executable
            if command -v "${pkg,,}" >/dev/null 2>&1 || \
               find /usr/bin /bin /sbin -name "*${pkg,,}*" 2>/dev/null | grep -q "."; then
                printf "${GREEN}✓ Installed${NC}\n"; SUCCESS=$((SUCCESS + 1))
            else printf "${RED}✗ Missing${NC}\n"; fi
            ;;
            
        "special")
            # Special checks for specific packages
            case "$pkg" in
                "Acl")
                    if command -v getfacl >/dev/null 2>&1 && command -v setfacl >/dev/null 2>&1; then
                        printf "${GREEN}✓ Installed${NC}\n"; SUCCESS=$((SUCCESS + 1))
                    else printf "${RED}✗ Missing${NC}\n"; fi
                    ;;
                
                "Attr")
                    if command -v getfattr >/dev/null 2>&1 && command -v setfattr >/dev/null 2>&1; then
                        printf "${GREEN}✓ Installed${NC}\n"; SUCCESS=$((SUCCESS + 1))
                    else printf "${RED}✗ Missing${NC}\n"; fi
                    ;;
                
                "Bc")
                    if command -v bc >/dev/null 2>&1; then
                        printf "${GREEN}✓ Installed${NC}\n"; SUCCESS=$((SUCCESS + 1))
                    else printf "${RED}✗ Missing${NC}\n"; fi
                    ;;
                
                "Check")
                    if command -v checkmk >/dev/null 2>&1 || [ -f /usr/lib/libcheck.so ] || [ -f /usr/include/check.h ]; then
                        printf "${GREEN}✓ Installed${NC}\n"; SUCCESS=$((SUCCESS + 1))
                    else printf "${RED}✗ Missing${NC}\n"; fi
                    ;;
                
                "E2fsprogs")
                    if command -v e2fsck >/dev/null 2>&1 || command -v tune2fs >/dev/null 2>&1; then
                        printf "${GREEN}✓ Installed${NC}\n"; SUCCESS=$((SUCCESS + 1))
                    else printf "${RED}✗ Missing${NC}\n"; fi
                    ;;
                
                "GDBM")
                    if [ -f /usr/lib/libgdbm.so ] || [ -f /usr/include/gdbm.h ] || command -v gdbm_load >/dev/null 2>&1; then
                        printf "${GREEN}✓ Installed${NC}\n"; SUCCESS=$((SUCCESS + 1))
                    else printf "${RED}✗ Missing${NC}\n"; fi
                    ;;
                
                "Gperf")
                    if command -v gperf >/dev/null 2>&1; then
                        printf "${GREEN}✓ Installed${NC}\n"; SUCCESS=$((SUCCESS + 1))
                    else printf "${RED}✗ Missing${NC}\n"; fi
                    ;;
                
                "Iana-Etc")
                    if [ -f /etc/protocols ] && [ -f /etc/services ]; then
                        printf "${GREEN}✓ Installed${NC}\n"; SUCCESS=$((SUCCESS + 1))
                    else printf "${RED}✗ Missing${NC}\n"; fi
                    ;;
                
                "Libpipeline")
                    if [ -f /usr/lib/libpipeline.so ] || [ -f /usr/include/pipeline.h ]; then
                        printf "${GREEN}✓ Installed${NC}\n"; SUCCESS=$((SUCCESS + 1))
                    else printf "${RED}✗ Missing${NC}\n"; fi
                    ;;
                
                "M4")
                    if command -v m4 >/dev/null 2>&1; then
                        printf "${GREEN}✓ Installed${NC}\n"; SUCCESS=$((SUCCESS + 1))
                    else printf "${RED}✗ Missing${NC}\n"; fi
                    ;;
                
                "Sysklogd")
                    if [ -f /usr/sbin/syslogd ] || [ -f /usr/sbin/klogd ] || [ -f /etc/syslog.conf ]; then
                        printf "${GREEN}✓ Installed${NC}\n"; SUCCESS=$((SUCCESS + 1))
                    else printf "${RED}✗ Missing${NC}\n"; fi
                    ;;
                
                "Time Zone Data")
                    if [ -d /usr/share/zoneinfo ] && [ -f /usr/share/zoneinfo/UTC ]; then
                        printf "${GREEN}✓ Installed${NC}\n"; SUCCESS=$((SUCCESS + 1))
                    else printf "${RED}✗ Missing${NC}\n"; fi
                    ;;
                # === CORE UTILITIES (check for key binaries) ===
                "Coreutils")
                    if command -v ls >/dev/null 2>&1 && command -v cp >/dev/null 2>&1 && command -v cat >/dev/null 2>&1; then
                        printf "${GREEN}✓ Installed${NC}\n"; SUCCESS=$((SUCCESS + 1))
                    else printf "${RED}✗ Missing${NC}\n"; fi
                    ;;
                
                "Findutils")
                    if command -v find >/dev/null 2>&1 && command -v xargs >/dev/null 2>&1; then
                        printf "${GREEN}✓ Installed${NC}\n"; SUCCESS=$((SUCCESS + 1))
                    else printf "${RED}✗ Missing${NC}\n"; fi
                    ;;
                
                "Diffutils")
                    if command -v diff >/dev/null 2>&1 && command -v cmp >/dev/null 2>&1; then
                        printf "${GREEN}✓ Installed${NC}\n"; SUCCESS=$((SUCCESS + 1))
                    else printf "${RED}✗ Missing${NC}\n"; fi
                    ;;
                "Sysvinit")
                    if [ -f /sbin/init ] || [ -f /sbin/telinit ]; then
                        printf "${GREEN}✓ Installed${NC}\n"; SUCCESS=$((SUCCESS + 1))
                    else printf "${RED}✗ Missing${NC}\n"; fi
                    ;;
                
                "Shadow")
                    if command -v passwd >/dev/null 2>&1 && [ -f /etc/shadow ]; then
                        printf "${GREEN}✓ Installed${NC}\n"; SUCCESS=$((SUCCESS + 1))
                    else printf "${RED}✗ Missing${NC}\n"; fi
                    ;;
                
                "Util-linux")
                    if command -v mount >/dev/null 2>&1 && command -v fdisk >/dev/null 2>&1; then
                        printf "${GREEN}✓ Installed${NC}\n"; SUCCESS=$((SUCCESS + 1))
                    else printf "${RED}✗ Missing${NC}\n"; fi
                    ;;
                
                "Procps")
                    if command -v ps >/dev/null 2>&1 && command -v top >/dev/null 2>&1; then
                        printf "${GREEN}✓ Installed${NC}\n"; SUCCESS=$((SUCCESS + 1))
                    else printf "${RED}✗ Missing${NC}\n"; fi
                    ;;
                
                "Psmisc")
                    if command -v killall >/dev/null 2>&1 && command -v pstree >/dev/null 2>&1; then
                        printf "${GREEN}✓ Installed${NC}\n"; SUCCESS=$((SUCCESS + 1))
                    else printf "${RED}✗ Missing${NC}\n"; fi
                    ;;
                
                "IPRoute2")
                    if command -v ip >/dev/null 2>&1 && command -v ss >/dev/null 2>&1; then
                        printf "${GREEN}✓ Installed${NC}\n"; SUCCESS=$((SUCCESS + 1))
                    else printf "${RED}✗ Missing${NC}\n"; fi
                    ;;
                
                "Inetutils")
                    if command -v ping >/dev/null 2>&1 && command -v ftp >/dev/null 2>&1; then
                        printf "${GREEN}✓ Installed${NC}\n"; SUCCESS=$((SUCCESS + 1))
                    else printf "${RED}✗ Missing${NC}\n"; fi
                    ;;
                "Time Zone Data")
                    # Check for timezone database files
                    if [ -d /usr/share/zoneinfo ] && [ -f /usr/share/zoneinfo/UTC ]; then
                        printf "${GREEN}✓ Installed${NC}\n"; SUCCESS=$((SUCCESS + 1))
                    else
                        printf "${RED}✗ Missing${NC}\n"
                    fi
                    ;;
                
                "Iana-Etc")
                    # Check for protocol and service files
                    if [ -f /etc/protocols ] && [ -f /etc/services ]; then
                        printf "${GREEN}✓ Installed${NC}\n"; SUCCESS=$((SUCCESS + 1))
                    else
                        printf "${RED}✗ Missing${NC}\n"
                    fi
                    ;;
                
                "Sysklogd")
                    # Check for system logging daemon
                    if [ -f /usr/sbin/syslogd ] || [ -f /usr/sbin/klogd ] || \
                       [ -f /etc/syslog.conf ] || [ -f /etc/rsyslog.conf ]; then
                        printf "${GREEN}✓ Installed${NC}\n"; SUCCESS=$((SUCCESS + 1))
                    else
                        printf "${RED}✗ Missing${NC}\n"
                    fi
                    ;;
                
                "E2fsprogs")
                    # Check for ext filesystem utilities
                    if command -v e2fsck >/dev/null 2>&1 || \
                       command -v tune2fs >/dev/null 2>&1 || \
                       command -v mkfs.ext4 >/dev/null 2>&1; then
                        printf "${GREEN}✓ Installed${NC}\n"; SUCCESS=$((SUCCESS + 1))
                    else
                        printf "${RED}✗ Missing${NC}\n"
                    fi
                    ;;
                
                # === DOCUMENTATION ===
                "Man-pages")
                    if [ -d /usr/share/man ] && [ -d /usr/share/man/man3 ]; then
                        printf "${GREEN}✓ Installed${NC}\n"; SUCCESS=$((SUCCESS + 1))
                    else printf "${RED}✗ Missing${NC}\n"; fi
                    ;;
                
                "Man-DB")
                    if command -v man >/dev/null 2>&1 && command -v apropos >/dev/null 2>&1; then
                        printf "${GREEN}✓ Installed${NC}\n"; SUCCESS=$((SUCCESS + 1))
                    else printf "${RED}✗ Missing${NC}\n"; fi
                    ;;
                "XML::Parser")
                    if [ -f /usr/lib/libexpat.so ] || perl -MXML::Parser -e "1" 2>/dev/null; then
                        printf "${GREEN}✓ Installed${NC}\n"; SUCCESS=$((SUCCESS + 1))
                    else printf "${RED}✗ Missing${NC}\n"; fi
                    ;;
                "Texinfo")
                    if command -v makeinfo >/dev/null 2>&1 && command -v info >/dev/null 2>&1; then
                        printf "${GREEN}✓ Installed${NC}\n"; SUCCESS=$((SUCCESS + 1))
                    else printf "${RED}✗ Missing${NC}\n"; fi
                    ;;
                "Glibc")
                    if [ -f /usr/lib/libc.so ] || [ -f /lib/libc.so.6 ]; then
                        printf "${GREEN}✓ Installed${NC}\n"; SUCCESS=$((SUCCESS + 1))
                    else printf "${RED}✗ Missing${NC}\n"; fi ;;
                "GCC")
                    if command -v gcc >/dev/null 2>&1; then
                        printf "${GREEN}✓ Installed${NC}\n"; SUCCESS=$((SUCCESS + 1))
                    else printf "${RED}✗ Missing${NC}\n"; fi ;;
                "GRUB")
                    if [ -f /usr/sbin/grub-install ] || [ -f /boot/grub/grub.cfg ]; then
                        printf "${GREEN}✓ Installed${NC}\n"; SUCCESS=$((SUCCESS + 1))
                    else printf "${RED}✗ Missing${NC}\n"; fi ;;
                "Eudev")
                    if command -v udevadm >/dev/null 2>&1 || [ -f /sbin/udevd ]; then
                        printf "${GREEN}✓ Installed${NC}\n"; SUCCESS=$((SUCCESS + 1))
                    else printf "${RED}✗ Missing${NC}\n"; fi ;;
                *)
                    printf "${YELLOW}⏭ No check defined${NC}\n"; ;;
            esac
            ;;
            
        *)
            printf "${YELLOW}⏭ Unknown type${NC}\n"; ;;
    esac
}

function show_results {
    echo -e "\n${BLUE}======================${NC}"
    echo -e "${BLUE}Verification Results${NC}"
    echo -e "${BLUE}======================${NC}"
    
    if [ $TOTAL -gt 0 ]; then
        PERCENT=$((100 * SUCCESS / TOTAL))
        echo -e "Packages found: ${SUCCESS}/${TOTAL}"
        echo -e "Success rate: ${PERCENT}%"
        
        # Show missing packages if any
        if [ $SUCCESS -lt $TOTAL ]; then
            echo -e "\n${YELLOW}Missing packages may need to be installed from:${NC}"
            echo "https://www.linuxfromscratch.org/lfs/view/stable/"
        fi
    fi
}

# ==================== Main Script ====================
clear
echo -e "${BLUE}==================================${NC}"
echo -e "${BLUE}LFS Package Verification Script${NC}"
echo -e "${BLUE}==================================${NC}"
echo -e "System: $(uname -srm)"
echo -e "Date: $(date)\n"

# ==================== Package Checks ====================
echo -e "${YELLOW}Checking Core Packages...${NC}"

check_package "Acl" "bin"
check_package "Attr" "bin"
check_package "Autoconf" "bin"
check_package "Automake" "bin"
check_package "Bash" "special"
check_package "Bc" "bin"
check_package "Binutils" "special"
check_package "Bison" "bin"
check_package "Bzip2" "bin"
check_package "Check" "bin"
check_package "Coreutils" "special"
check_package "DejaGNU" "bin"
check_package "Diffutils" "special"
check_package "Eudev" "special"
check_package "E2fsprogs" "special"
check_package "Expat" "lib"
check_package "Expect" "bin"
check_package "File" "bin"
check_package "Findutils" "special"
check_package "Flex" "bin"
check_package "Gawk" "bin"
check_package "GCC" "special"
check_package "GDBM" "bin"
check_package "Gettext" "bin"
check_package "Glibc" "special"
check_package "GMP" "lib"
check_package "Gperf" "bin"
check_package "Grep" "bin"
check_package "Groff" "bin"
check_package "GRUB" "special"
check_package "Gzip" "bin"
check_package "Iana-Etc" "special"
check_package "Inetutils" "special"
check_package "Intltool" "bin"
check_package "IPRoute2" "special"
check_package "Kbd" "bin"
check_package "Kmod" "bin"
check_package "Less" "bin"
check_package "Libpipeline" "lib"
check_package "Libcap" "lib"
check_package "Libtool" "bin"
check_package "M4" "bin"
check_package "Make" "bin"
check_package "Man-DB" "special"
check_package "Man-pages" "special"
check_package "MPC" "lib"
check_package "MPFR" "lib"
check_package "Ncurses" "lib"
check_package "Patch" "bin"
check_package "Perl" "bin"
check_package "Pkg-config" "bin"
check_package "Procps" "special"
check_package "Psmisc" "special"
check_package "Readline" "lib"
check_package "Sed" "bin"
check_package "Shadow" "special"
check_package "Sysklogd" "special"
check_package "Sysvinit" "special"
check_package "Tar" "bin"
check_package "Tcl" "lib"
check_package "Texinfo" "special"
check_package "Time Zone Data" "special"
check_package "Udev" "lib"
check_package "Util-linux" "special"
check_package "Vim" "bin"
check_package "XML::Parser" "special"
check_package "Xz" "bin"
check_package "Zlib" "lib"

# ==================== Results ====================
show_results

exit 0