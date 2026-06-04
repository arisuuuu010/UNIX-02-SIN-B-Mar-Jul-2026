#! /bin/bash
touch test && touch123
(ls; ps)
ls; ps; whoami
lzl || echo "El comando lzl fallo"

echo "uno" > file.txt
echo "dos" > file.txt
echo "uno-uno" >> file.txt

echo "3" &> file1.txt
echo "3" &>> file1.txt

ls -l / &> stdout_and_stderr.txt
ls -l / 1> stdout.txt 2> stderr.txt

cat < file1.txt
#3
#3

cat << EOF
Black Hat Bash
by No Starch Press
EOF