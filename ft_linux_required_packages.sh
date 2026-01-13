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
                
                # === DOCUMENTATION ===
                "Man-pages")
                    if [ -d /usr/share/man ] && [ -f /usr/share/man/man1/ls.1.gz ]; then
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

# Group 1: Libraries (usually have .so files)
echo -e "\n${BLUE}[Libraries]${NC}"
check_package "Glibc" "special"
check_package "GMP" "lib"
check_package "MPFR" "lib"
check_package "MPC" "lib"
check_package "Zlib" "lib"
check_package "Expat" "lib"
check_package "Libcap" "lib"
check_package "XML::Parser" "lib"

# Group 2: Binaries (have executables)
echo -e "\n${BLUE}[Binaries/Tools]${NC}"
check_package "Bash" "special"
check_package "Coreutils" "bin"
check_package "Findutils" "bin"
check_package "Grep" "bin"
check_package "Sed" "bin"
check_package "Gawk" "bin"
check_package "Tar" "bin"
check_package "Gzip" "bin"
check_package "Bzip2" "bin"
check_package "Xz" "bin"
check_package "Make" "bin"
check_package "Patch" "bin"
check_package "Diffutils" "bin"
check_package "File" "bin"

# Group 3: System Tools
echo -e "\n${BLUE}[System Tools]${NC}"
check_package "Binutils" "special"
check_package "GCC" "special"
check_package "GRUB" "special"
check_package "Eudev" "special"
check_package "Sysvinit" "special"
check_package "Shadow" "bin"
check_package "Util-linux" "bin"
check_package "Procps" "bin"
check_package "Psmisc" "bin"
check_package "Kbd" "bin"
check_package "Kmod" "bin"
check_package "IPRoute2" "bin"
check_package "Inetutils" "bin"

# Group 4: Development Tools
echo -e "\n${BLUE}[Development Tools]${NC}"
check_package "Autoconf" "bin"
check_package "Automake" "bin"
check_package "Libtool" "bin"
check_package "Bison" "bin"
check_package "Flex" "bin"
check_package "Pkg-config" "bin"
check_package "Gettext" "bin"
check_package "Intltool" "bin"

# Group 5: Documentation & Misc
echo -e "\n${BLUE}[Documentation & Misc]${NC}"
check_package "Man-pages" "lib"
check_package "Man-DB" "bin"
check_package "Texinfo" "bin"
check_package "Groff" "bin"
check_package "Vim" "bin"
check_package "Less" "bin"
check_package "Ncurses" "lib"
check_package "Readline" "lib"
check_package "Perl" "bin"
check_package "Tcl" "lib"
check_package "Expect" "bin"
check_package "DejaGNU" "bin"

# ==================== Results ====================
show_results

exit 0