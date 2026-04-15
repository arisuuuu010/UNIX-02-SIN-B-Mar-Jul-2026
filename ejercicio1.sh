echo '#!/bin/sh' > hola.sh (In the new script hola.sh the content is #!/bin/sh )
echo 'echo "Hola desde mi primer script" >> hola.sh (Here we can  add more information)
cat hola.sh (With can we can see the content)
./hola.sh (Execute command but we need chmod +x hola.sh)

ls -l hola.sh (List the files)
chmod +x hola.sh (We have the permissions to execute the script)
ls -l hola.sh (List the files)
./hola.sh(Execute the command)

ls /etc (ls list )
sudo touch /etc/prueba.txt (We need use sudo to touch configurations)
 mkdir ~/mi_carpeta (We can create a new file but in our home ~)
sudo apt install cowsay (Install cowsay)