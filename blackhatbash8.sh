#! /bin/bash
awk ' {print $1,$2,$3}' log.txt
awk ' {print $1}' log.txt
awk ' {print $2}' log.txt
awk ' {print $3}' log.txt
awk ' {print $1,$NF}' log.txt
awk ' {print $NF}' log.txt

                    