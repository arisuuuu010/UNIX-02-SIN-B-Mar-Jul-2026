Cisco Homework
1.ls //ls is a basic command in linux, ls list files and directories in the computer
we have some examples add to ls, like, ls -h, ls -a, ls -lah, each one give more information than single file.
When I read the mean of ls in the course, a fun fact that I find out is, linux has case sensitive, it means depends on if the 
command has uppercase or not and if the command has space or not.
Also commands get structure:
1.command
2.options
3.arguments
2.ls Documents //Actually when we talk about command structure, we have a good example like ls Documents, the function is give all
the documents that you have in your computer.
3.aptitude moo command is a multi-layered Easter egg found in the Aptitude package manager on Debian-based Linux distributions
if you want play with the command you can use, -v, example, aptitude -v moo
4.ls -l // If you want more information in a large screen you can use ls -l, you get information like, permissions. dates, etc.
5.ls -r //When you run a standard ls command, the system displays your files and folders in alphabetical order. The -r flag tells the terminal to flip that list upside down, sorting from Z to A instead of A to Z.
ls -l -r
ls -rl
ls -lr
//they have the same function as ls -r with more information.
6.pwd //When you type this into your terminal and hit Enter, it tells you exactly where you are currently located in the file system hierarchy.
7.cd //When you wnat change your space, cd help you, because cd means change directory.
cd Documents, when we run this commands, we change to Documents.
cd /, we run this command to go the root
cd /home/sysadmin, we can change our directory if we specified the place
cd .., we can up one place
8.ls -l /var/log/  is one of the most important directories because it is the central hub where the system and its applications store log files—records of everything from system crashes to login attempts.
ls -lt /var/log/ this options give us the information date of each command
ls -l -s /var/log It will sort the files by file size
ls -lSr /var/log change the order from smallest to largest
9.su // when we use su, it means we are admins into the terminal.
sl //usually triggers a Steam Locomotive to chug across your screen but we need execute the command like rootuser
10.cd ~/Documents //This command change the directory to documents in root
ls -l hello.sh // with l we can see more information in the file, like the permissions