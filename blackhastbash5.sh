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