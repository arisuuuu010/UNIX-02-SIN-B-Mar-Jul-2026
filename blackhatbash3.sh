#!/bin/bash
book="black hat bash"
echo "This book's name is ${book}" 
echo "This book's name is $book"
# bash -x blackhatbash3.sh (verbose moode)


 root_directory=$(ls -ld /)
 echo "${root_directory}"
 
  book="Black Hat Bash"
  unset book
  echo "${book}"