echo '#!/bin/sh' > hola.sh (In the new script hola.sh the content is #!/bin/sh )
echo 'echo "Hola desde mi primer script" >> hola.sh (Here we can  add more information)
cat hola.sh (With can we can see the content)
./hola.sh (Execute command but we need chmod +x hola.sh)

ls -l hola.sh
chmod +x hola.sh
ls -l hola.sh
./hola.sh