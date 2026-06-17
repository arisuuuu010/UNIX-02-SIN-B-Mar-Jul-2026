#! /bin/bash
awk ' {print $1,$2,$3}' log.txt
awk ' {print $1}' log.txt
awk ' {print $2}' log.txt
awk ' {print $3}' log.txt
awk ' {print $1,$NF}' log.txt
awk ' {print $NF}' log.txt


#head log.txt 
#The command show the 10 lines

#13.66.139.0 - - [19/Dec/2020:13:57:26 +0100] "GET /index.php?option=com_phocagallery&view=category&id=1:almhuette-raith&Itemid=53 HTTP/1.1" 200 32653 "-" "Mozilla/5.0 (compatible; bingbot/2.0; +http://www.bing.com/bingbot.htm)" "-"
#157.48.153.185 - - [19/Dec/2020:14:08:06 +0100] "GET /apache-log/access.log HTTP/1.1" 200 233 "-" "Mozilla/5.0 (Windows NT 6.3; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/87.0.4280.88 Safari/537.36" "-"
#157.48.153.185 - - [19/Dec/2020:14:08:08 +0100] "GET /favicon.ico HTTP/1.1" 404 217 "http://www.almhuette-raith.at/apache-log/access.log" "Mozilla/5.0 (Windows NT 6.3; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/87.0.4280.88 Safari/537.36" "-"
#216.244.66.230 - - [19/Dec/2020:14:14:26 +0100] "GET /robots.txt HTTP/1.1" 200 304 "-" "Mozilla/5.0 (compatible; DotBot/1.1; http://www.opensiteexplorer.org/dotbot, help@moz.com)" "-"
#54.36.148.92 - - [19/Dec/2020:14:16:44 +0100] "GET /index.php?option=com_phocagallery&view=category&id=2%3Awinterfotos&Itemid=53 HTTP/1.1" 200 30662 "-" "Mozilla/5.0 (compatible; AhrefsBot/7.0; +http://ahrefs.com/robot/)" "-"
#92.101.35.224 - - [19/Dec/2020:14:29:21 +0100] "GET /administrator/index.php HTTP/1.1" 200 4263 "" "Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; SV1; .NET CLR 1.1.4322)" "-"
#73.166.162.225 - - [19/Dec/2020:14:58:59 +0100] "GET /apache-log/access.log HTTP/1.1" 200 1299 "-" "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/87.0.4280.101 Safari/537.36" "-"
#73.166.162.225 - - [19/Dec/2020:14:58:59 +0100] "GET /favicon.ico HTTP/1.1" 404 217 "http://www.almhuette-raith.at/apache-log/access.log" "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/87.0.4280.101 Safari/537.36" "-"
#54.36.148.108 - - [19/Dec/2020:15:09:30 +0100] "GET /robots.txt HTTP/1.1" 200 304 "-" "Mozilla/5.0 (compatible; AhrefsBot/7.0; +http://ahrefs.com/robot/)" "-"

#[Ariel_Yumbillo] /workspaces/UNIX-02-SIN-B-Mar-Jul-2026 ok $ 

awk 'NR < 10' log.txt
grep "42.236.10.117" log.txt | awk '{print $7}'

sed 's/Modzilla/Godzilla/g' log.txt
sed 's/mozilla/Godzilla/gi' log.txt > newlog.txt
ls -lh newlog.txt
grep -i "Godzilla" newlog.txt
sed 's/ //g' log.txt
sed '1d' log.txt
sed '$d' log.txt
sed -n '2,15 p' log.txt
sed -i '1d' log.txt

#[Ariel_Yumbillo] /workspaces/UNIX-02-SIN-B-Mar-Jul-2026 ok $ 
#We can use sleep 100 and execute 
sleep 100 &
#[1] 25737


#[Ariel_Yumbillo] /workspaces/UNIX-02-SIN-B-Mar-Jul-2026 ok $ 
#Lists all running processes and filters for the word "sleep".
ps -ef | grep sleep
#root           1       0  0 12:12 ?        00:00:00 /bin/sh -c echo Container started trap "exit 0" 15  exec "$@" while sleep 1 & wait $!; do :; done -
#root       25737     346  0 13:13 pts/0    00:00:00 sleep 100
#root       25843       1  0 13:13 ?        00:00:00 sleep 1
#root       25850     346  0 13:13 pts/0    00:00:00 grep --color=auto sleep

#[Ariel_Yumbillo] /workspaces/UNIX-02-SIN-B-Mar-Jul-2026 ok $
#Shows tasks currently managed by this specific shell session. 
jobs
#[1]+  Ejecutando                 sleep 100 &

#[Ariel_Yumbillo] /workspaces/UNIX-02-SIN-B-Mar-Jul-2026 ok $ 
#'fg' (foreground) takes Job ID 1 (%1) and brings it to the front.
fg %1
#sleep 100