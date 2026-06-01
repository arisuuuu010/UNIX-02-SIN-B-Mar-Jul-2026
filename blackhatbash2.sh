#!/bin/bash 
# All this script does is create a directory, create a file
# within the directory, and then list the contents of the di rectory.
set -x #It shows the commands being executed and debugs (start)
mkdir mydirectory
touch mydirectory/myfile
 ls -l mydirectory
 set +x #It shows the commands being executed and debugs (end)

 #[Ariel_Yumbillo] /workspaces/UNIX-02-SIN-B-Mar-Jul-2026 ok $ bash -n blackhatbash2.sh (When we use -n, we can being debug the script)

#[Ariel_Yumbillo] /workspaces/UNIX-02-SIN-B-Mar-Jul-2026 ok $ bash -x blackhatbash2.sh (When we use -x we have more infromation about each command)
#+ set -x
#+ mkdir mydirectory
#mkdir: cannot create directory ‘mydirectory’: El fichero ya existe
#+ touch mydirectory/myfile
#+ ls -l mydirectory
#total 0
#-rw-rw-rw- 1 root root 0 jun  1 13:22 myfile
#+ set +x

#[Ariel_Yumbillo] /workspaces/UNIX-02-SIN-B-Mar-Jul-2026 ok $ ./blackhatbash2.sh 
#+ mkdir mydirectory
#mkdir: cannot create directory ‘mydirectory’: El fichero ya existe
#+ touch mydirectory/myfile
#+ ls -l mydirectory
#total 0
#-rw-rw-rw- 1 root root 0 jun  1 13:22 myfile
#+ set +x

#[Ariel_Yumbillo] /workspaces/UNIX-02-SIN-B-Mar-Jul-2026 ok $ 