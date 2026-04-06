## / (Main directory, it helps to know the place that we are)
# cd (Change directory, when we want change the directory we use cd and the name of the place)
#Example: cd /home/codespace
# cd ~ (Is a shortcut used to change your current working directory to your Home directory)
#cd $HOME  
#but $HOME is wrong beacuse we cant use $ if we want change the directory
#mkdir (we can create a file in the terminal, using mkdir and if want romove a file, we use rmdir)
# ls -lai (List files, but give us hide information)
total 12 #(Here we have . and .., the are hidden files and when we use lai, we can wacth it)
925555 drwxr-xr-x 2 codespace codespace 4096 Apr  6 12:35 . #(The numbers are the inodos, it means the ids of each file)
918515 drwxr-x--- 1 codespace codespace 4096 Apr  6 12:35 ..
# $stat (Give all the metadata information such as: block, inodos, soft links and hard links and block)
#fun fact: Blocks are different amount IO BLOCKS bacause each BLOCK ponly use512 bytes, but if we multiply each block for 8
#we have 4096 that is all the bytes about each block)
#/dev/sda (It only means disks, and in windows call C OR D)
#Device = 0.45 (It means a virtual disk but if you have a diffrent number is a material disk)
 # man mkdir (manual information)
 #man ls
# -p means the father of the system
# man mkdir (manual of the file that we crate)
#If we use stat /tmp/prueba again, device change to 8,1, so the file use a material disk
# pwd (Where am I?)
#whoami(Who am I?)
# ls (Whats there)
 #ls
 #ls -l
 #ls -la
 #ls -lh
 

#When was modify each file?
#ls -lt

#What there are at the root of the system?
#ls /

#Explore system directories 
#ls /etc | head -20 (list the 20 firts lines about configuration)
#ls /dev | head -20 (list the 20 firts lines about devices)
 
  