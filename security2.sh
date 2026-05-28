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

