#!/usr/bin/env bash

red='\e[31m'
yellow='\e[33m'
green="\e[32m"
blue='\e[34m'
gray='\033[1;30m'
white='\033[1;37m'
normal=$(tput sgr0)

LOG_FILE=apk_prepare.log
echo "" > $LOG_FILE
print_both_sides() {
    fix_tput=$(($(tput cols)+10))
    if [[ $# == 2 ]];then
        printf "\r%*b\r%b\n" ${fix_tput} "$2" "$1";
    else
        printf "\r%*b\r%b" ${fix_tput} "$2" "$1";
    fi
}
log_title() {
    middle=$((($(tput cols)-${#1})/2))
    s=$(printf "%-$(tput cols)s" "+")
    plus_row="${s// /+}"
    echo $plus_row >> $LOG_FILE
    s=$(printf "%-${middle}s" " ")
    spaces="${s// /_}"
    echo $spaces$1$spaces >> $LOG_FILE
    echo $plus_row >> $LOG_FILE
}
print_usage()
{
    print_both_sides "${green}Usage:$normal ${blue}apk_prepare${normal} -f <target.apk> [-o <output folder>] " "${gray}# If -o empty, will create folder in current dir.$normal"
}

OUTFOLDER=""
for WORD; do
        case $WORD in
            -f)  if [[ ${2:0:1} != "-" && ${2:0:1} != "" ]] ; then
                 APK_FILE=$2
                 shift 2
                else
                 print_usage
                 exit 1
                fi ;;
            -o)  if [[ ${2:0:1} != "-" && ${2:0:1} != "" ]] ; then
                 OUTFOLDER=$2
                 shift 2
                 else
                    print_both_sides "[$yellow+$normal] No output folder was provided, project will be created in current directory " "[${yellow}WARNING$normal]"
                 fi ;;
            -h)  print_usage
                 exit 0
                 ;;
            -*) print_usage
                exit 1
            ;;
        esac
done
if [[ -z "$APK_FILE" ]];then
    echo -e "[$red+$normal] Please provide an apk file."
    print_usage
    exit 1
elif [[ "$APK_FILE" != *".apk" ]];then
    echo -e "[$red+$normal] Wrong extention; Please provide an apk."
    exit 1
elif [[ ! -f "$APK_FILE" ]];then
    print_both_sides "[$red+$normal] File does not exist; Please provide apk." "[${red}ERROR$normal]"
    exit 1
fi
if [ -z $OUTFOLDER ];then
    OUTFOLDER=${APK_FILE%".apk"}
fi

#apktools
echo -e "[$blue+$normal] Running apktool."
output=$(apktool d -o $OUTFOLDER "$APK_FILE" 2>&1)
if [[ $output == *"Use -f switch if you want to overwrite it."* ]];then
    print_both_sides "[$yellow+$normal] Target folder \"${yellow}$OUTFOLDER${normal}\" already exists; Delete and recreate? (y/n): " "[${yellow}WARNING$normal]" ""
    read response
    if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]];then
            echo -e "[$blue+$normal] Deleting previous folder."
            rm -rf $OUTFOLDER
            echo -e "[$blue+$normal] Running apktool."
            output=$(apktool d -o ${OUTFOLDER} "$APK_FILE" 2>&1)
        else
            OUTFOLDER="${OUTFOLDER}_2"
            echo -e "[$blue+$normal] Running apktool. Target folder $OUTFOLDER"
            output=$(apktool d -o ${OUTFOLDER} "$APK_FILE" 2>&1)
    fi
fi
log_title "APKTOOL"
echo -e "$output\n" >> $LOG_FILE
print_both_sides "[$green+$normal] apktool finished execution succesfully." "[${green}OK$normal]"
FILENAME=${APK_FILE%".apk"}

#apk-->dex
echo -e "[$blue+$normal] Extracting dex from the apk."

output=$(d2j-jar2dex -f $APK_FILE 2>&1)
log_title "D2J-JAR2DEX"
echo -e "$output\n" >> $LOG_FILE
if [[ ! -f "$FILENAME-jar2dex.dex" ]];then
    print_both_sides "[$red+$normal] Jar2dex failed. View $LOG_FILE for more information" "[${red}ERROR$normal]"
    exit 1
else
    print_both_sides "[$green+$normal] The dex file was succesfully converted to jar." "[${green}OK$normal]"
fi

#dex-->jar
echo -e "[$blue+$normal] Converting dex to jar."
output=$(d2j-dex2jar -f $FILENAME-jar2dex.dex 2>&1)
log_title "D2J-DEX2JAR"
echo -e "$output\n" >> $LOG_FILE
if [[ ! -f "$FILENAME-jar2dex-dex2jar.jar" ]];then
    print_both_sides "[$red+$normal] Dex2jar failed. View $LOG_FILE for more information" "[${red}ERROR$normal]"
    exit 1
else
    print_both_sides "[$green+$normal] The dex file was succesfully converted to jar." "[${green}OK$normal]"
fi

#jar --> Java
echo -e "[$blue+$normal] Converting jar to Java source."
output=$(jadx $FILENAME-jar2dex-dex2jar.jar 2>&1)
log_title "JADX"
echo -e "$output\n" >> $LOG_FILE
if [[ $output == *"ERROR"* ]];then
    if [[ ! -d "$FILENAME-jar2dex-dex2jar" ]];then
        print_both_sides "[$red+$normal] JADX failed. View $bold$LOG_FILE$normal for more information" "[${red}ERROR$normal]"
        exit 1
    else
        print_both_sides "[$yellow+$normal] JADX finished with errors" "[${yellow}WARNING$normal]"
    fi
else
    print_both_sides "[$green+$normal] JADX finished succesfully." "[${green}OK$normal]"
fi

#CleanUp
echo -e "[$green+$normal] Cleaning up."
mv $FILENAME-jar2dex-dex2jar $OUTFOLDER/src
rm -rf  $FILENAME-jar2dex-dex2jar.jar $FILENAME-jar2dex.dex

#Install APK
echo -e "[$blue+$normal] Attempting to install apk to device."
installed=0
echo -e "[$blue+$normal] Starting adb-server."
adb start-server 2>&1 >/dev/null
if [[ $(adb devices) == "List of devices attached" ]];then
    print_both_sides "[$yellow+$normal] No device is attached. Will terminate without ." "[${yellow}WARNING$normal]"
else
    output=$(adb install $APK_FILE 2>&1)
    if [[ "$output" == *"INSTALL_FAILED_ALREADY_EXISTS"* ]];then
        print_both_sides "[$yellow+$normal] apk already installed on device. Reinstall? (y/n): " "[${yellow}WARNING$normal]" ""
        read response
        if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]];then
            output=$(adb install -r $APK_FILE 2>&1)
        else
            installed=1
        fi
    elif [[ "$output" == *"INSTALL_FAILED_UPDATE_INCOMPATIBLE"* ]];then
        print_both_sides "[$yellow+$normal] An other version of the apk is installed on the device, should I uninstall and reinstall? (y/n): " "[${yellow}WARNING$normal]" ""
        read response
        if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]];then
            PACKAGE_NAME=$(grep -oP 'package=\"(.*)$' $OUTFOLDER/AndroidManifest.xml | grep -o '".*"' | sed 's/"//g' | awk '{print $1;}')
            print_both_sides "[$yellow+$normal] Will uninstall $PACKAGE_NAME, ok? (y/n): " "[${yellow}WARNING$normal]" ""
            read response
            if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]];then
                output=$(adb uninstall $PACKAGE_NAME 2>&1)
                output=$(adb install $APK_FILE 2>&1)
            else
                print_both_sides "[$yellow+$normal] Will not proceed with installation, please install manualy ." "[${yellow}WARNING$normal]"
                installed=1
            fi
        else
            installed=1
        fi
    fi
    if [[ "$output" == *"INSTALL_FAILED_INVALID_APK"* ]];then
        print_both_sides "[$red+$normal] apk failed to install due to it being invalid." "[${red}ERROR$normal]"
    elif [[ "$output" == *"Success"* ]];then
        print_both_sides "[$green+$normal] apk installed succesfully." "[${green}OK$normal]"
        installed=1
    elif [[ $installed -eq 0 ]];then
        print_both_sides "[$yellow+$normal] Installation process unsucessful. Try installing it manualy. View $bold$LOG_FILE$normal for more information" "[${yellow}WARNING$normal]"
    fi
fi
log_title "adb install"
echo -e "$output\n" >> $LOG_FILE
if [[ $installed -eq 0 ]];then
    print_both_sides "[$green+$normal] Android  application package was succesfully prepared, not installed on device." "[${yellow}WARNING$normal]"
else
    print_both_sides "[$green+$normal] Android  application package was succesfully prepared and installed on device." "[${green}OK$normal]"
fi
