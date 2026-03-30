sudo apt update 
#How the name said, update all the files and versions from repositories in systems linux
#We use it when we want install a new program and we need verify the versions and if we dont have problems
sudo apt upgrade
#download and install new versions. this means software realeses
#sudo apt update && sudo apt upgrade -y (This commmand is automatic, update and upgrade in a one line)
sudo apt install parted 
#Help to install GNU parted, it is a tool in linux that manages disk partitions

##First we use update. second upgrade and the end install

sudo parted -l && echo -e "\n--\n" && lsblk -f && echo -e "\n---\n"
##parted -l (partitions disks could be mbr or gpt)
##lsblk -f (estructure disks and free spaces)
#mount | grep (Where is the device) 
#&& It means the logic gate and, and it verify if the newt command is true
#-e (it can speak special characteres)

[ -d/sys/firmware/efi ] && echo "UEFI" || echo "BIOS"
#Its a fast test to verify what terminal we use in our virtual machine bios or uefi in my case was UEFI it is different
#[ Start test
# -d (verify if is a directory)
#/sys/firmware/efi (The way to the file EFI)
#] end test

FHS #(jerarquy tree)
 lost+found/ #(It can helps to recover our files when the computer is power off)
/run #(System data run)
/tmp #(Temporary files, its like a temporary garbage dump)

echo "esto es un archivo" >archivo.txt #(With echo we can create a file wuth a namea information)
stat archivo.txt #(Stat give all the information that we need to know) also in class we can see that a simply message like esto es un archivo use only 19 bytes and we hace 4k bites it is a big difference


