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
#If all its okey we can use:
gpg --list-keys
#echo = We use echo to show in console
#>= It is the filter to txt
 echo "hola andres" >doc_no_cifrado.txt
 #The code creates a new file in binary
 gpg --output Holaandrestilinjaja.txt --encrypt --recipient 10764728C8B9C7F941FCF5F49CE2A432BF706712 doc_no_cifra
do.txt
#My partner sent me the file. so I need descrypt the file and with the code, it shows the message
 $ gpg --decrypt holaarieltilin.txt
#Create a new file with our sign 
 gpg --output docfirmado.txt --clearsign doc_no_cifrado.txt
#Verify the sign
gpg --verify doc_no_cifrado_firmado.txt
#We can edit the key and tyhe confidence
 gpg --edit-key 10764728C8B9C7F941FCF5F49CE2A432BF706712
 # Do the file in binary
 gpg --output doc_no_cifrado_firmado_binario.txt --sign doc_no_cifrado.txt