
# Ft_linux - How to Train Your Kernel

|[Author: marza-ga@student.42barcelona.com](https://www.github.com/codemarc42)|  ![Estado del Proyecto](https://img.shields.io/badge/ESTADO-Completado-success)  |
|-----------|----------------------|

## 📖 Descripción

**ft_linux** es un proyecto avanzado que consiste en construir desde cero una distribución Linux funcional y personalizada. El objetivo principal no es la programación del kernel en sí, sino dominar el proceso completo de creación de un sistema operativo: desde la compilación del kernel Linux hasta la configuración del espacio de usuario (userspace), instalación de paquetes esenciales e implementación de una jerarquía de sistema de archivos estándar.

## 🎯 Objetivos del Proyecto

- **Compilar un Kernel Linux** desde su código fuente, con personalizaciones específicas.
- **Instalar un conjunto fundamental** de binarios y herramientas (lista detallada más abajo).
- **Implementar una jerarquía de sistema de archivos** (Filesystem Hierarchy Standard - FHS).
- **Configurar la conectividad de red** para que el sistema pueda acceder a Internet.
- **Crear una base sólida y personalizada** que servirá como entorno de desarrollo para futuros proyectos de kernel.
## 📋 Tabla de Contenidos

- [Requisitos Técnicos](#⚙️-requisitos-técnicos)
- [Paquetes Obligatorios](#📦-paquetes-obligatorios)
- [Guía de Instalación](#🚀-guía-de-instalación)
- [Estructura del Repositorio](#📁-estructura-del-repositorio)
- [Parte Bonus](#✨-parte-bonus)
- [Evaluación y Entrega](#📝-evaluación-y-entrega)
- [Recursos y Referencias](#📚-recursos-y-referencias)
## Preparar Maquina de Desarollo

- **Virtual Box:** Elegimos desarrollar sobre un maquina Debian 13

Debemos prepar una maquina de desarollo que contenga las herramientas y especificaciones para poder compilar y desarrollar nuestro Kernel. Para ello disponemos de este script de dependencias, lo ejectuamos y debemos intallar las dependencias y paquetes que nos falten.



Script version-check.sh: (
https://www.linuxfromscratch.org/lfs/view/stable/chapter02/hostreqs.html )
```bash
cat > version-check.sh << "EOF"
#!/bin/bash
# A script to list version numbers of critical development tools

# If you have tools installed in other directories, adjust PATH here AND
# in ~lfs/.bashrc (section 4.4) as well.

LC_ALL=C 
PATH=/usr/bin:/bin

bail() { echo "FATAL: $1"; exit 1; }
grep --version > /dev/null 2> /dev/null || bail "grep does not work"
sed '' /dev/null || bail "sed does not work"
sort   /dev/null || bail "sort does not work"

ver_check()
{
   if ! type -p $2 &>/dev/null
   then 
     echo "ERROR: Cannot find $2 ($1)"; return 1; 
   fi
   v=$($2 --version 2>&1 | grep -E -o '[0-9]+\.[0-9\.]+[a-z]*' | head -n1)
   if printf '%s\n' $3 $v | sort --version-sort --check &>/dev/null
   then 
     printf "OK:    %-9s %-6s >= $3\n" "$1" "$v"; return 0;
   else 
     printf "ERROR: %-9s is TOO OLD ($3 or later required)\n" "$1"; 
     return 1; 
   fi
}

ver_kernel()
{
   kver=$(uname -r | grep -E -o '^[0-9\.]+')
   if printf '%s\n' $1 $kver | sort --version-sort --check &>/dev/null
   then 
     printf "OK:    Linux Kernel $kver >= $1\n"; return 0;
   else 
     printf "ERROR: Linux Kernel ($kver) is TOO OLD ($1 or later required)\n" "$kver"; 
     return 1; 
   fi
}

# Coreutils first because --version-sort needs Coreutils >= 7.0
ver_check Coreutils      sort     8.1 || bail "Coreutils too old, stop"
ver_check Bash           bash     3.2
ver_check Binutils       ld       2.13.1
ver_check Bison          bison    2.7
ver_check Diffutils      diff     2.8.1
ver_check Findutils      find     4.2.31
ver_check Gawk           gawk     4.0.1
ver_check GCC            gcc      5.4
ver_check "GCC (C++)"    g++      5.4
ver_check Grep           grep     2.5.1a
ver_check Gzip           gzip     1.3.12
ver_check M4             m4       1.4.10
ver_check Make           make     4.0
ver_check Patch          patch    2.5.4
ver_check Perl           perl     5.8.8
ver_check Python         python3  3.4
ver_check Sed            sed      4.1.5
ver_check Tar            tar      1.22
ver_check Texinfo        texi2any 5.0
ver_check Xz             xz       5.0.0
ver_kernel 5.4

if mount | grep -q 'devpts on /dev/pts' && [ -e /dev/ptmx ]
then echo "OK:    Linux Kernel supports UNIX 98 PTY";
else echo "ERROR: Linux Kernel does NOT support UNIX 98 PTY"; fi

alias_check() {
   if $1 --version 2>&1 | grep -qi $2
   then printf "OK:    %-4s is $2\n" "$1";
   else printf "ERROR: %-4s is NOT $2\n" "$1"; fi
}
echo "Aliases:"
alias_check awk GNU
alias_check yacc Bison
alias_check sh Bash

echo "Compiler check:"
if printf "int main(){}" | g++ -x c++ -
then echo "OK:    g++ works";
else echo "ERROR: g++ does NOT work"; fi
rm -f a.out

if [ "$(nproc)" = "" ]; then
   echo "ERROR: nproc is not available or it produces empty output"
else
   echo "OK: nproc reports $(nproc) logical cores are available"
fi
EOF

bash version-check.sh
```
## Crear Disco Duro Virtual

Propósito principal
Creamos un disco duro virtual (ft_linux.vdi) como entorno aislado y seguro para construir nuestro sistema Linux desde cero (LFS). Este disco virtual estara asociado a nuestra Maquina de desarrollo para ello con esta apagada vamos a:

Cofiguracion -> Almacenamiento -> Controlador Sata

1 - Clicamos sobre este y entonces en el icono de crear nuevo disco

2 - Clicamos sobre crear disco, y creamos disco de 30Gb llamado ft_linux.vdi

3 - Clicamos en añadir y lo añadimos a nuestra maquina de desarrollo

## LFS System: Particionar el disco duro virtual

## 📊 Distribución para un disco de 30 GB

| Partición      | Tamaño  | % del Disco | Propósito para Pentesting                                                                 |
|----------------|---------|-------------|-------------------------------------------------------------------------------------------|
| **`/boot`**    | 500 MB  | ~1.7%       | Kernel personalizado (`vmlinuz-<version>-<login>`), GRUB e initramfs. Capacidad para múltiples versiones. |
| **`swap`**     | 4 GB    | ~13.3%      | Memoria virtual crítica para herramientas intensivas (hashcat, Metasploit framework).      |
| **`/` (root)** | 10 GB   | ~33.3%      | Sistema base LFS + herramientas esenciales compiladas desde fuente.                        |
| **`/home`**    | 5 GB    | ~16.7%      | Directorio personal y proyectos activos de pentesting (scripts, informes, capturas).      |
| **`/opt`**     | 10.5 GB | ~35%        | **Zona de herramientas grandes:** Metasploit Framework, Burp Suite, bases de datos de vulnerabilidades, wordlists masivos. |

## 1. Identificar y Limpiar el Disco Virtual:
```bash
root@vbox:/home/marza-ga# sudo lsblk
NAME   MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS
sda      8:0    0 40.2G  0 disk 
├─sda1   8:1    0 39.3G  0 part /
├─sda2   8:2    0    1K  0 part 
└─sda5   8:5    0  976M  0 part [SWAP]
sdb      8:16   0   30G  0 disk <------ Nuestra disco duro virtual (ft_linux.dbi) 
sr0     11:0    1 56.1M  0 rom  
```

Si necesitaramos borrar particiones del disco duro virtual:

```bash
sudo wipefs -a /dev/sdb
```

## 2. Crear Tabla de Particiones y Particiones con fdisk

**La opción g en fdisk o gdisk crea una nueva tabla de particiones GPT (GUID Partition Table) en el disco.**

```bash
sudo fdisk /dev/sdb

Welcome to fdisk (util-linux 2.38.1).
Changes will remain in memory only, until you decide to write them.
Be careful before using the write command.

Device does not contain a recognized partition table.
Created a new DOS (MBR) disklabel with disk identifier 0x36aec243.

Command (m for help): g      <--- important!!!!!
Created a new GPT disklabel (GUID: 5307C1DC-D5AF-B445-9B1C-AE77DF2BCEA5).

```

### 2.1 Partición /boot (500 MB)
n -> Enter -> Enter -> +500M

### 2.2 Partición swap (4 GB)
n -> Enter -> Enter -> +4G

### 2.3 Partición / (root) (10 GB)
n -> Enter -> Enter -> +10G

### 2.4 Partición /home (5 GB)
n -> Enter -> Enter -> +5G

### 2.5 Partición /opt (usa EL RESTO, ~10.5 GB)
n -> Enter -> Enter -> Enter (Rest of space)

### 2.6 Verificar que todo quedó bien
**Con la opcion p podemos verificar que todo quedo bien**

```bash
Command (m for help): p
Disk /dev/sdb: 30 GiB, 32212254720 bytes, 62914560 sectors
Disk model: VBOX HARDDISK   
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: gpt
Disk identifier: 21D70F54-1AB4-F740-AA92-0CF8C3FC6960

Device        Start      End  Sectors  Size Type
/dev/sdb1      2048  1026047  1024000  500M Linux filesystem
/dev/sdb2   1026048  9414655  8388608    4G Linux filesystem
/dev/sdb3   9414656 30386175 20971520   10G Linux filesystem
/dev/sdb4  30386176 40871935 10485760    5G Linux filesystem
/dev/sdb5  40871936 62912511 22040576 10.5G Linux filesystem

```

### 2.7 Aplicar los cambios
w       # Escribir tabla en disco y salir

```bash
Command (m for help): w
The partition table has been altered.
Calling ioctl() to re-read partition table.
Syncing disks.

```


## 3. Formatear y montar todas las particiones
```bash
# 1. Formatear todas las particiones
sudo mkfs.ext4 /dev/sdb1
sudo mkswap /dev/sdb2 && sudo swapon /dev/sdb2
sudo mkfs.ext4 /dev/sdb3
sudo mkfs.ext4 /dev/sdb4
sudo mkfs.ext4 /dev/sdb5

# 2. Configurar y crear punto de montaje
export LFS=/mnt/lfs
sudo mkdir -pv $LFS

# 3. Montar la partición raíz y luego las demás
sudo mount /dev/sdb3 $LFS
sudo mkdir -pv $LFS/{boot,home,opt}
sudo mount /dev/sdb1 $LFS/boot
sudo mount /dev/sdb4 $LFS/home
sudo mount /dev/sdb5 $LFS/opt
```

## 4. Activar y verificar SWAPON
```bash
sudo apt update && sudo apt install util-linux
sudo swapon /dev/sdb2
lsblk -f | grep sdb2

Filename		Type		Size		Used	Priority
/dev/sda5      partition	999420		0	          -2
/dev/sdb2      partition	4194300		0	          -3
               total        used        free      shared  buff/cache   available
Mem:           7.6Gi       1.5Gi       5.4Gi        20Mi       991Mi       6.1Gi
Swap:          5.0Gi          0B       5.0Gi
├─sdb2 swap    1    16da3a1a-aa5c-4f67-9e8c-7815abf3c29b      [SWAP]

```

## 4. Preparación del Entorno de Construcción (Maquina Virtual Host de Desarrollo)

https://www.linuxfromscratch.org/lfs/view/stable/chapter02/aboutlfs.html

https://www.linuxfromscratch.org/lfs/view/stable/chapter02/mounting.html

Antes de compilar el sistema, se debe preparar un entorno aislado y seguro en el sistema anfitrión (Debian). Estos pasos son críticos para garantizar una construcción limpia y reproducible. Objetivos de esta Preparación: Aislar el entorno de construcción del sistema anfitrión,Evitar contaminación con bibliotecas o configuraciones del host, garantizar permisos correctos en todos los archivos generados y crear un usuario dedicado (lfs) para mayor seguridad.

### 4.1 FASE 1: Como usuario root actual

```bash
bash
# 1. Configurar entorno base
export LFS=/mnt/lfs
umask 022

# 2. Verificar configuración
echo "=== Verificación inicial ==="
echo "LFS: $LFS"
echo "umask: $(umask)"
echo "============================"

# 3. Ajustar permisos del punto de montaje
sudo chown root:root $LFS
sudo chmod 755 $LFS

# 4. Crear directorios esenciales
sudo mkdir -v $LFS/sources
sudo mkdir -v $LFS/tools

# 5. Dar permisos especiales a sources
sudo chmod -v a+wt $LFS/sources

# 6. Crear enlace simbólico CRÍTICO
sudo ln -sv $LFS/tools /

# 7. Crear usuario lfs
sudo groupadd lfs
sudo useradd -s /bin/bash -g lfs -m -k /dev/null lfs

# 8. Establecer contraseña para lfs (escribe 'lfs' cuando te lo pida)
sudo passwd lfs

# 9. Transferir propiedad de directorios
sudo chown -v lfs $LFS/tools
sudo chown -v lfs $LFS/sources

```
Nos preguntara un password para el usurio lfs, cualquiera nos vale.

### 4.2 FASE 2: Cambiar al usuario lfs
```bash
su - lfs
```

### 4.3 FASE 3: Como usuario lfs - Configurar entorno
```bash
# 1. Crear .bash_profile
cat > ~/.bash_profile << "EOF"
exec env -i HOME=$HOME TERM=$TERM PS1='\u:\w\$ ' /bin/bash
EOF

# 2. Crear .bashrc
cat > ~/.bashrc << "EOF"
set +h
umask 022
LFS=/mnt/lfs
LC_ALL=POSIX
LFS_TGT=$(uname -m)-lfs-linux-gnu
PATH=/usr/bin
if [ ! -L /bin ]; then PATH=/bin:$PATH; fi
PATH=$LFS/tools/bin:$PATH
CONFIG_SITE=$LFS/usr/share/config.site
export LFS LC_ALL LFS_TGT PATH CONFIG_SITE
EOF

# 3. Cargar la nueva configuración
source ~/.bash_profile
```

### 4.4 FASE 4: Verificación FINAL

```bash
lfs@vbox:~$ 
echo "1. Variable LFS: $LFS"
echo "2. umask: $(umask)"
echo "3. PATH: $PATH"
echo "4. Usuario actual: $(whoami)"
echo "5. Directorio actual: $(pwd)"

1. Variable LFS: /mnt/lfs
2. umask: 0022
3. PATH: /mnt/lfs/tools/bin:/usr/bin
4. Usuario actual: lfs
5. Directorio actual: /home/lfs

```


## Instalacion de Paquetes y Paches

## 📦 Paquetes Obligatorios

A continuación se detallan los paquetes esenciales que deben instalarse en el sistema. Los paquetes marcados con (*) son ejemplos y pueden ser reemplazados por equivalentes.

| Categoría | Paquetes Principales |
|-----------|----------------------|
| **Shell y Utilidades Básicas** | Bash*, Coreutils, Findutils, Grep, Sed, Gawk, Diffutils, File, Less, Man-DB, Man-pages, Readline, Time Zone Data |
| **Suite de Compilación** | GCC, Make, Binutils, Autoconf, Automake, Libtool, M4, Bison, Flex, Pkg-config, Gettext, Intltool, Gperf |
| **Sistema y Bibliotecas** | Glibc, Zlib, Bzip2, Xz, Gzip, Ncurses, Readline, Attr, Acl, Libcap, MPFR, GMP, MPC |
| **Administración del Sistema** | Shadow, Sysvinit*, Eudev*, Util-linux, Kmod, Procps, Psmisc, IPRoute2, Kbd, Sysklogd |
| **Red y Comunicaciones** | Inetutils, Iana-Etc |
| **Procesamiento de Texto** | Vim*, Groff, Texinfo |
| **Herramientas de Desarrollo** | GDBM, Expat, XML::Parser, Check, DejaGNU, Expect, Tcl |
| **Otros Esenciales** | Bc, Check, E2fsprogs, Libpipeline, Patch, Perl |

**Nota importante**: Para fines de evaluación, el sistema debe poder **descargar código fuente** (se recomienda instalar `curl` o `wget`) y **instalar paquetes** adicionales.

## 📦 Paquetes Recomdandos LFS

La fuente principal y recomendada para obtener los paquetes es la **lista oficial de LFS**:
- **Enlace oficial**: https://www.linuxfromscratch.org/lfs/view/stable/wget-list-sysv
- **Uso práctico**: Este archivo contiene prácticamente todos los paquetes obligatorios para `ft_linux`, además de algunos adicionales recomendados por LFS.


```bash

https://download.savannah.gnu.org/releases/acl/acl-2.3.2.tar.xz
https://download.savannah.gnu.org/releases/attr/attr-2.5.2.tar.gz
https://ftp.gnu.org/gnu/autoconf/autoconf-2.72.tar.xz
https://ftp.gnu.org/gnu/automake/automake-1.18.1.tar.xz
https://ftp.gnu.org/gnu/bash/bash-5.3.tar.gz
https://github.com/gavinhoward/bc/releases/download/7.0.3/bc-7.0.3.tar.xz
https://sourceware.org/pub/binutils/releases/binutils-2.45.tar.xz
https://ftp.gnu.org/gnu/bison/bison-3.8.2.tar.xz
https://www.sourceware.org/pub/bzip2/bzip2-1.0.8.tar.gz
https://ftp.gnu.org/gnu/coreutils/coreutils-9.7.tar.xz
https://ftp.gnu.org/gnu/dejagnu/dejagnu-1.6.3.tar.gz
https://ftp.gnu.org/gnu/diffutils/diffutils-3.12.tar.xz
https://downloads.sourceforge.net/project/e2fsprogs/e2fsprogs/v1.47.3/e2fsprogs-1.47.3.tar.gz
https://sourceware.org/ftp/elfutils/0.193/elfutils-0.193.tar.bz2
https://github.com/libexpat/libexpat/releases/download/R_2_7_1/expat-2.7.1.tar.xz
https://prdownloads.sourceforge.net/expect/expect5.45.4.tar.gz
https://astron.com/pub/file/file-5.46.tar.gz
https://ftp.gnu.org/gnu/findutils/findutils-4.10.0.tar.xz
https://github.com/westes/flex/releases/download/v2.6.4/flex-2.6.4.tar.gz
https://pypi.org/packages/source/f/flit-core/flit_core-3.12.0.tar.gz
https://ftp.gnu.org/gnu/gawk/gawk-5.3.2.tar.xz
https://ftp.gnu.org/gnu/gcc/gcc-15.2.0/gcc-15.2.0.tar.xz
.......
....... and more
```

Nos decargamos el fichero ya que nos sera de mucha utilidad.

## 📦 Descargar Paquetes y Paches Recomendandos por LFS

Anteriormente ya creamos la carpeta sources, asi que nos dirigimos a ella:
```bash
cd $LFS/sources
```

Ejecutamos varias veces este comando hasta que hayamos descargado todos los archivos
```bash
wget --input-file=wget-list-sysv --continue 
```

Verificar con checkSums que todos los archivos se descargaron completamente, para ello usaremos los checksums que nos proporciona LFS

**Descargar y copiar en el directorio:** https://www.linuxfromscratch.org/lfs/view/stable/md5sums 

```bash
 md5sum -c md5sums
```
Si todo sale OK, es que hemos completado todas las descargas

Borramos archivos inecesarios y cambiamos el grupo y propietario de los ficheros en source a root:root
```bash
rm md5sums
rm wget-list-sysv
chown root:root $LFS/sources/*
```


# Preparaciones Finales

Antes de empezar a compilar los paquetes, debemos acabar de preparar el FileSystem y el usuario para las compilaciones

## Creating a Limited Directory Layout in the LFS Filesystem

The first step is to create a limited directory hierarchy, so that the programs compiled in Chapter 6 (as well as glibc and libstdc++ in Chapter 5) can be installed in their final location. We do this so those temporary programs will be overwritten when the final versions are built in Chapter 8.

Con usuario root ejecutamos
```bash
mkdir -pv $LFS/{etc,var} $LFS/usr/{bin,lib,sbin}

for i in bin lib sbin; do
  ln -sv usr/$i $LFS/$i
done

case $(uname -m) in
  x86_64) mkdir -pv $LFS/lib64 ;;
esac
```

Programs in Chapter 6 will be compiled with a cross-compiler (more details can be found in section Toolchain Technical Notes). This cross-compiler will be installed in a special directory, to separate it from the other programs. Still acting as root, create that directory with this command:

```bash
mkdir -pv $LFS/tools
```

## Adding the LFS User
```bash
groupadd lfs
useradd -s /bin/bash -g lfs -m -k /dev/null lfs
```

If you want to log in as lfs or switch to lfs from a non-root user (as opposed to switching to user lfs when logged in as root, which does not require the lfs user to have a password), you need to set a password for lfs. Issue the following command as the root user to set the password:
```bash
passwd lfs
```

Grant lfs full access to all the directories under $LFS by making lfs the owner:

```bash
chown -v lfs $LFS/{usr{,/*},var,etc,tools}
case $(uname -m) in
  x86_64) chown -v lfs $LFS/lib64 ;;
esac
```

Next, start a shell running as user lfs. This can be done by logging in as lfs on a virtual console, or with the following substitute/switch user command:
```bash
su - lfs
```

## Setting Up the Environment