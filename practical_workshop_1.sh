uname -a
which gpg 
gpg --version
#empieza con un punto y es un archivo oculto
#RSA 4096, son bits universales
gpg --full-generate-key
gpg --list-keys
gpg --armor --export yumbilloariel@gmail.com > mi_llave_publica.asc
#list private keys
gpg --list-secret-keys --keyid-format=long
#If we have some keys in our list, we need specifie the  hash, it means, we need to use the sec
gpg --armor --export-secret-keys 70571C1279AE9727
#We can  list our pair of keys and we execute:
gpg --armor --export-secret-keys
#In this moment, we are wortking in pairs and the first step is list our keys
gpg --list-keys
#We need download the file (mypartner)
#Then use to import andres
gpg --import andres_llave_publica.asc