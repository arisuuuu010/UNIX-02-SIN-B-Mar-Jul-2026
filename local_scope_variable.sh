#!/bin/bash

# Definition of a global variable (accessible from anywhere in the script)
PUBLISHER="No Starch Press"

# Definition of the 'print_name' function
print_name(){
     # Declares 'name' as a local variable.
     # This means it will only exist WITHIN this function.
     local name 
     
     # Assigns a value to the local variable
     name="Black Hat Bash"
     
     # Prints the string combining both the local and global variables
     echo "${name} by ${PUBLISHER}"
}

# Calls the function to execute its code
print_name

# This command attempts to print the 'name' variable.
# Since 'name' was declared as 'local' inside the function, it is undefined out here.
# The text will print, but the variable's slot will be completely blank.
echo "Variable ${name} will not be printed because it is a local variable."