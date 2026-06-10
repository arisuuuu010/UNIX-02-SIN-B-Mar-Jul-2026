#!/bin/bash
USER_INPUT="${1}" #Create a global variable called user input
if [[ -z "${USER_INPUT}" ]]; then # if the command has null use echo to who you must provide an argument
 echo you must provide an argument!
 exit 1 #the numer 1 exit
fi #finish this part because the so said "we have a fail"

if [[ -f "${USER_INPUT}" ]]; then echo "${USER_INPUT} is a file" # if you use a argument the masagge is a directory
elif [[ -d "${USER_INPUT}" ]]; then
 echo "${USER_INPUT} is a directory"
else #if the bash doesnt have arguments the mesagge will be is not  a file or a diretcory
echo "${USER_INPUT} is not a file or a directory"  
fi