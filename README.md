# UNIX-02-SIN-B-Mar-Jul-2026
Repo for the subject intoduction to unix
1. **Kernel Linux** The core of the OS
2. **Busy box** Basic shortcuts like, pwd, ls, vi, etc in a single binary
2. **Syslinux** bootloader to run all the OS

sudo apt update
sudo apt upgrade
sudo apt install -y git vim make gcc libncurses-dev flex bison cpio libelf-dev libssl-dev syslinux dosfstools qemu-system-x86

**What is the funcionality of each package?
qcc,make- complicacion del kernel y busy box
libncurses-dec- menus interactivos de configuracion (menuconfig)    
flex,bison, bc - requeridos por el proceso de build del kernel
cpio- para crear el initramsfs
libelf-dev, libssl-dev- dependencias del kernel 
syslinu- el bootloader
dosfstools- para crear el filesystem FAT 
qemu-syste,-x86- para probar la imagen sin nesecidad de hardward real

git clone --depth 1 https://github.com/torvalds/linux.git
cd linux (change to the new directory call linux)
make menuconfig (Create a new menu, graphic interface)
make -j 2 ( -j 2 Use 2 cores )
sudo cp arch/x86/boot/bzImage /boot-files/
cd .. (here the code cpy the bzImage in binary)
git clone --depth 1 https://git.busybox.net/busybox
cd busybox (In a single code we have busy box, busy box gives special characters)
nano .config (To enter at file .config and configure TC with n)
make menuconfig (configurate a graphic interface)
sudo mkdir /boot-files/initramfs (This code hepl to download initram (It is a mini OS to help update drivers))

 sudo make CONFIG_PREFIX=/boot-files/initramfs install (We install the initram)