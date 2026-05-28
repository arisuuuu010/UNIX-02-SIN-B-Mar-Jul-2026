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