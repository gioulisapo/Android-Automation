#!/usr/bin/env bash
bold=$(tput bold)
red='\033[0;31m'
blue='\033[0;34m'
yellow='\033[1;33m'
green="\033[0;32m"
gray='\033[1;30m'
white='\033[1;37m'
normal=$(tput sgr0)

if [[ -z "$1" ]];then
    echo -e "[$red+$normal] Please provide an apk file to be signed."
    exit 1
elif [[ "$1" != *".apk" ]];then
    echo -e "[$red+$normal] File should be of the apk format."
    exit 1
fi
java -jar /usr/local/bin/sign.jar $1
arrIN=(${1//./ })
echo -e "[$green+$normal] Signed apk ${green}$arrIN.s.apk${normal} was produced."