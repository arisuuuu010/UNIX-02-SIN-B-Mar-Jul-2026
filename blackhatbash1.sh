#!/bin/bash -x 
set -x
#(It shows the commands being executed)
#--Commands---
 bash --version
env
echo ${SHELL
echo ${RANDOM}}
echo ${UID}
echo ${OSTYPE}
ps -ef
 df --human-readable
#We can execute the script in restricted mode using -r option
# bash -r blackhatbash1.sh
#When we use -n we can debug the script whitout executing it
# bash -n blackhatbash1.sh
set +x