
#!/usr/bin/env bash

red='\e[31m'
yellow='\e[33m'
green="\e[32m"
blue='\e[34m'
gray='\033[1;30m'
white='\033[1;37m'
normal=$(tput sgr0)

if [[ -z "$1" ]];then
    echo -e "[$red+$normal] Please provide the name of the screenshot."
    exit 1
fi
FILENAME=$1

OUTPUT=""
CUR_DIR=$(pwd)
if [[ $CUR_DIR == *"challenges"* ]] || [[ $CUR_DIR == *"testing"* ]];then
    flag=0
    IFS='/' read -ra ADDR <<< "$CUR_DIR"
    for i in "${ADDR[@]}"; do
        if [[ $flag -eq 1 ]];then
            OUTPUT="$OUTPUT/$i/screenshots/"
            break
        fi
        if [[ $i == *"challenges"* ]] || [[ $i == *"testing"* ]];then
            flag=1
            if [[ $i == *"challenges"* ]];then
                OUTPUT="/home/$USER/Documents/challenges"
            else
                OUTPUT="/home/$USER/Documents/testing"
            fi
        fi
    done
else
    OUTPUT="$(pwd)/"
fi

if [[ "$FILENAME" == *".png" ]];then
    OUTPUT="${OUTPUT}$FILENAME"
elif [[ "$FILENAME" == *".jpg" ]] || [[ "$FILENAME" == *".jpeg" ]];then
    OUTPUT="${OUTPUT}$(echo $FILENAME | cut -f 1 -d '.').png"
else
    OUTPUT="${OUTPUT}$FILENAME.png"
fi
while true;do
    if [[ -f $OUTPUT ]];then
        OUTPUT="$(echo $OUTPUT | cut -f 1 -d '.')"
        NUMBER="$(echo $OUTPUT | cut -f 2 -d '_')"
        re='^[0-9]+$'
        if ! [[ $NUMBER =~ $re ]];then
            NUMBER=1
        else
            NUMBER=$(($NUMBER+1))
        fi
        OUTPUT="$(echo $OUTPUT | cut -f 1 -d '_')"
        OUTPUT="${OUTPUT}_$NUMBER.png"
    else
        break
    fi
done
adb shell screencap -p | perl -pe 's/\x0D\x0A/\x0A/g' > $OUTPUT
echo -e "[$green+$normal] Screenshot was created at \"${yellow}$(realpath --relative-to="`pwd`" "$OUTPUT")${normal}\""