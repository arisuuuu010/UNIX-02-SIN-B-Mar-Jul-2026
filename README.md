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

 #!/bin/sh
/bin/sh (The firts line said the kernel that uses shell and second line said start a interactive shell)

sudo rm linuxrc
sudo chmod +x init (By removing linuxrc and giving init executable permissions, we are essentially transitioning the boot logic or preparing a custom initramfs.)

sudo find . | cpio -o -H newc > ../init.cpio
cd ..
but it command it was wrong on my computer so I USE 
sudo sh -c 'find . | cpio -o -H newc > ../init.cpio'

Switch to root for the following steps (this simplifies permissions):
sudo su
Create an empty 50 MB file to serve as a virtual disk:
dd if=/dev/zero of=boot bs=1M count=50
Create a FAT filesystem in that file (required by Syslinux):
mkfs -t fat boot
syslinux boot
mkdir m
mount boot m
cp bzImage init.cpio m
umount mq

so in this moment i can do it, i give up, but I can do it again 
So I repeat all the steps again hahaha, but when i end the activity, all is well.
next and end step
qemu-system-x86_64 -nographic -append "console=ttyS0"  -kernel bzImage -initrd init.cpio -drive file=boot,format=raw
(That command is the execution order for QEMU to boot your system. Basically, you are telling the virtual machine exactly how it should "assemble" itself to work.)


**Activities**
Explain the purpose of each directory listed by the previous command in the context of BusyBox:
The path /boot-files/initramfs/ refers to the Initial RAM File System directory, which serves as a temporary, minimalist operating system layout that your kernel loads into memory during the boot process. It acts as a staging area where you have installed BusyBox to provide essential commands (like ls and sh) and where your init script lives to tell the kernel how to start the system.
1. Verify the firmware type: Run `[ -d /sys/firmware/efi ] && echo "UEFI" ||
echo "BIOS"` both in the codespace and within QEMU. What result do you get and why?
 When  I run the code in my codespace and in my minidistro , the result was BIOS, because into github the most popular firmware is Bios and the virtual machine gives us this option, is the same in our minidistro. 

2. Inspect the structure: Within QEMU, run `ls /` and compare it to the directory structure we saw in class. Which directories are missing and why?
When I ran ls / into my minidistro, the files that we have are, bin, dev, init, sbin and usr, but the difference with the directory structure, we are missing some directories, such as boot, etc,home, live, tmp and var, the cause is that we create the distro into the ram, no into the disk
3. Explore BusyBox: Within QEMU, run `ls -la /bin/` and observe that all the commands are symbolic links to the same binary. What advantage does this have for an embedded system?
The main advantage of using symbolic links pointing to a single BusyBox binary is storage efficiency. In embedded systems with limited resources, having one multi-call binary instead of hundreds of separate executables significantly reduces the disk footprint.

4. Examine blocks: In the codespace, create a file with `echo "hello" > test.txt` and then run `stat test.txt`. Identify the actual size versus the allocated blocks. Is there internal fragmentation? 
The actual size is 6 bytes, but the system has allocated 8 blocks, each size are 512 bytes, it means we have 4096 unusable bytes. There is significant internal fragmentation because the file does not fill the entire logical block
5. Analyze partitions: Run `sudo parted -l && echo -e "\n---\n" && lsblk -f` on the codespace. This identifies which disks use GPT vs. MBR, and which filesystems are in use.
The system uses the GPT (GUID Partition Table) scheme, as identified by the parted -l command. GPT is the modern standard replacing the legacy MBR. Regarding the filesystems, the output shows that ext4 is being used for the main partitions, which is the standard journaling filesystem for Linux, providing a balance between performance and data integrity.
