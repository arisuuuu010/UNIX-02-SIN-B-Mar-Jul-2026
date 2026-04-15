
The structure that we have in a linux command are, command, options and arguments
ls -a (Short command, if we want a fast typing (hacking NASA)) 
ls --all (Large command, the better use is when we reading scripts) 
In both cases are similar, the mean of each one is give me all the files
also the structure in both commands are, command and option.

ls -l -a -h (This command help us wehn we know all the files with every information of each one, it means, hidden files, dates and who is the propietarie.)
ls -l -ah (With this commmand we have the same information)
ls -lah (-lah is better when we want a fast typing (Hacking FBI))

mkdir -- -rf (We use -- because -r is a option that means strong remove, and helping us with --, linux thinks that the new of the directory is rf)
rmdir -- -rf (We use rmdir when we want remove sepcific file)


(In both commands re have the infoormstion about the command like ls)
ls --help (Here we have the resumize of the ls command)
man ls (When we use man, is the all the manual and how can we use, and the options next the command, it means all the information)

man git-clone (Clones a repository into a newly created directory, creates remote-tracking branches for
       each branch in the cloned repository (visible using git branch --remotes), and creates and
       checks out an initial branch that is forked from the cloned repository’s currently active
       branch.

       After the clone, a plain git fetch without arguments will update all the remote-tracking
       branches, and a git pull without arguments will in addition merge the remote master branch
       into the current master branch, if any (this is untrue when "--single-branch" is given;
       see below).)


chmod +x script.sh (All the people can execute the script)
chmod u+x script.sh (U = users and x = execute, said, only users can execute the script)
chmod o-r script.sh (O= others and - =less and r = read, it means others cannot read the script)
chmod u+rw,go-rwx script.sh (u = users + = can  r = read w = write, go = group and others - = less r =read w = write and x =execure)
it means Users can read and write the script, in the other hand, group and others cannot read, write and execute the script.

sudo echo "hola" > /etc/archivo_protegido (Here we have a problem like, the frist commmand part has sudo, it means, all the athorized permissions , in the other hand, the other command after > doesnt have permissions)
echo "hola" | sudo tee /etc/archivo_protegido > /dev/null (This command its netter than use  the redirection >, because we can executre this command with a pipeline and the sudo must be for all the command, however/dev/null, dont let see the content)
cat /etc/archivo_protegido(We can use cat to see the file content)
echo "hola" | sudo tee /etc/archivo_protegido (We have the same, however /dev/null are eliminated, and the command give the content wehn we executre it)


