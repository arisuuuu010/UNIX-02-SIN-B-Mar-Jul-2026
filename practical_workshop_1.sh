uname -a
which gpg 
gpg --version
#empieza con un punto y es un archivo oculto
#RSA 4096, son bits universales
gpg --full-generate-key
gpg --list-keys
gpg --armor --export yumbilloariel@gmail.com > mi_llave_publica.asc
