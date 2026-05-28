id 
id -gn #It can show the name of the main group
#Create a file and see which group inherits
touch ~/test_grupo_heredado.txt 
ls -la ~/test_grupo_heredado.txt
#The group is the main group of the user.

#See the group in my case vscode
echo "Grupo actual: $(id -gn)" 
#Create a new file before use of newgrp
touch ~/antes_de_newgrp.txt
ls -la ~/antes_de_newgrp.txt

newgrp #In my case i need to install the dependencies about newgrp
#@arisuuuu010 ➜ /workspaces/UNIX-02-SIN-B-Mar-Jul-2026 (security2) $ newgrp desarrolladores
#newgrp: group 'desarrolladores' does not exist

id -gn
#@arisuuuu010 ➜ /workspaces/UNIX-02-SIN-B-Mar-Jul-2026 (security2) $ echo "Nuevo grupo activo $(id -gn)"
#Nuevo grupo activo desarrolladores
# It shows how can we change the group

#Create a new file in the subshell
touch ~/dentro_de_newgrp.txt
ls -la ~/dentro_de_newgrp.txt

#Now hte group is desarrolladores
#Create a directory
mkdir -p ~/proyecto_dev/src
ls -la ~/

#@arisuuuu010 ➜ /workspaces/UNIX-02-SIN-B-Mar-Jul-2026 (security2) $ ls -la ~/
#total 56
#drwxr-xr-x  1 vscode vscode          4096 May 28 02:56 .
#drwxr-xr-x  1 root   root            4096 May 18 14:31 ..
#-rw-------  1 vscode vscode          1265 May 28 02:49 .bash_history
#-rw-r--r--  1 vscode vscode          2114 May 18 14:31 .bashrc
#drwxr-xr-x  3 vscode vscode          4096 May 28 02:23 .cache
#drwxr-xr-x  1 vscode vscode          4096 May 28 02:23 .config
#drwxr-xr-x  3 vscode vscode          4096 May 28 02:23 .dotnet
#drwxr-xr-x 13 vscode vscode          4096 May 18 14:31 .oh-my-zsh
#drwxr-xr-x  5 vscode vscode          4096 May 28 02:23 .vscode-remote
#-rw-r--r--  1 vscode vscode            22 May 18 14:31 .zprofile
#-rw-r--r--  1 vscode vscode          4018 May 18 14:31 .zshrc
#-rw-r--r--  1 vscode vscode             0 May 28 02:31 antes_de_newgrp.txt
#-rw-r--r--  1 vscode desarrolladores    0 May 28 02:55 dentro_de_newgrp.txt
#drwxr-xr-x  3 vscode desarrolladores 4096 May 28 02:56 proyecto_dev
#-rw-r--r--  1 vscode vscode             0 May 28 02:28 test_grupo_heredado.txt

#Exit of the subshell
exit
#Verify if you return to the original group
id -gn
echo "Grupo restaurado: $(id -gn)"
#@arisuuuu010 ➜ /workspaces/UNIX-02-SIN-B-Mar-Jul-2026 (security2) $ ls -la ~/antes_de_newgrp.txt ~/dentro_de_newgrp.txt
#-rw-r--r-- 1 vscode vscode          0 May 28 02:31 /home/vscode/antes_de_newgrp.txt
#-rw-r--r-- 1 vscode desarrolladores 0 May 28 02:55 /home/vscode/dentro_de_newgrp.txt

echo "PID del shell actual : $$"
#@arisuuuu010 ➜ /workspaces/UNIX-02-SIN-B-Mar-Jul-2026 (security2) $ echo "PID del shell actual : $$"
#PID del shell actual : 16502

#The new process in the subshell are more bigger than the main shell
 newgrp desarrolladores
 echo "PID dentro de newgrp: $$" 
#PID dentro de newgrp: 18054

sudo groupadd grupo_restringido
sudo gpasswd grupo_restringido
#Changing the password for group grupo_restringido
#New Password: 
#Re-enter new password:   like 123     
newgrp grupo_restringido
#Password: arielman2008