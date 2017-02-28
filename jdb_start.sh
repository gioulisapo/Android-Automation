#!/usr/bin/env bash
bold=$(tput bold)
red='\033[0;31m'
yellow='\033[1;33m'
green="\033[0;32m"
gray='\033[1;30m'
white='\033[1;37m'
normal=$(tput sgr0)


if [[ -z "$1" ]];then
    echo -e "[$red+$normal] Please provide name or pattern of target application."
    exit 1
fi
TARGET=$(echo "$1" | awk '{print tolower($0)}')
psresult="$(adb shell ps | grep "$TARGET")"
count=$(adb shell ps | grep "$TARGET" | wc -l)
stringarray=($psresult)

if [[ -z "$psresult" ]];then
    echo -e "[$red+$normal] No applications named \"*$bold$TARGET$normal*\" were found running in the device."
    exit 1
fi
if [[  $count > 1 ]]; then
    echo -e "[$yellow+$normal] More than one application was found matching given patern. Choose amongst the available options:"
    for i in $(seq 0 $count);do
        app_name="${stringarray[$(($i * 9 +8))]}"
        if [[ -z  $app_name ]];then
            continue
        else
            if [[ $app_name == *"google"* ]] || [[ $app_name == *"android"* ]] || [[ $app_name == *"/system/"* ]] || [[ $app_name == *"cyanogenmod"* ]] || [[ $app_name == *"com.qualcomm"* ]] || [[ $app_name != *"."* ]];then
                echo -e "     $i) $app_name"
            else
                echo -e "     $i)$green $app_name$normal"
            fi
        fi
    done
    option="-1"
    echo -en "[$yellow+$normal] please provide value between 0 and $(($count - 1)): "
    while [[ $option -lt "0" ]] || [[ $option -gt "$count" ]];do
        read option
        if [[ $option -lt "0" ]] || [[ $option -gt "$count" ]];then 
            echo -en "[$yellow+$normal] please provide value between 0 and $(($count - 1)): "
        fi
    done
else
    option=0
fi
echo -e "[$green+$normal] Will attach to PID $bold${stringarray[$(($option * 9 +1))]}$normal $red${stringarray[$(($option * 9 +8))]}$normal"
adb forward tcp:12345 jdwp:${stringarray[$(($option * 9 +1))]}
rlwrap_flag=1
hash  rlwrap-jdb 2>/dev/null || {  echo -en "[$yellow+$normal] ${green}rlwrap-jdb${normal} was is not installed. For your own convience install and run again"; rlwrap_flag=0; }
if [[ $rlwrap_flag -eq 1 ]];then
    rlwrap-jdb jdb -attach localhost:12345 2> /dev/null
    recode=$?
    if [[ $recode -ne 1 ]] && [[ $recode -ne 130 ]];then # 130: Script terminated by Control-Choose
        echo -e "[$yellow+$normal] ${green}rlwrap-jdb${normal} failed to run, will try jdb without wrapper."
        jdb -attach localhost:12345
    else
        exit 0
    fi
else
    jdb -attach localhost:12345
fi
