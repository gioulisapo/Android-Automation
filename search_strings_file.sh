#!/usr/bin/env bash
red='\e[31m'
yellow='\e[33m'
green="\e[32m"
blue='\e[34m'
gray='\033[1;30m'
italics='\033'
white='\033[1;37m'
normal=$(tput sgr0)
SAMPLE_CONFIG="password\ntoken\nsalt\nkey\nadmin\nmd5"
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

print_usage()
{
    echo -e "${green}Usage:$normal ${blue}search_strings_file${normal} -t <target_folder> [-c <target_config_file>][-h]"
    echo -e "       To add aditional keywords to search for add them to the $DIR/search_strings_config file"
    echo -e "       with default contents:"
    echo -e "\e[3m${SAMPLE_CONFIG}\e[0m" | sed 's/^/       /'
}

for WORD; do
        case $WORD in
            -t)  if [[ ${2:0:1} != "-" && ${2:0:1} != "" ]] ; then
                 TARGETDIR=$2
                 shift 2
                else
                 print_usage
                 exit 1
                fi ;;
            -c) CONFIG=$2
                shift 2
                 ;;
            -h)  print_usage
                 exit 0
                 ;;
            -*) print_usage
                exit 1
            ;;
        esac
done
# CHECK USER INPUT
if [[ -z "$TARGETDIR" ]];then
    echo -e "[$red+$normal] Please provide a target foder."
    print_usage
    exit 1
elif [[ ! -d "$TARGETDIR" ]];then
    echo -e "[$red+$normal] Please provide a valid target foder."
    print_usage
    exit 1
fi
# CHECK IF CONFIG EXISTS IF NOT CREATE
if [[ -z "$CONFIG" ]] && [[ ! -f "$DIR"/.search_strings_config ]];then
    echo -e "[$yellow+$normal] Unable to locate config file. Sample config generated: "$DIR"/.search_strings_config."
    echo -e "$SAMPLE_CONFIG" > "$DIR/.search_strings_config"
    CONFIG="$DIR/.search_strings_config"
elif [[ -z "$CONFIG" ]] && [[ -f "$DIR"/.search_strings_config ]];then
    CONFIG="$DIR/.search_strings_config"
fi

# FIRST RUN HTTP CHECK
http_links=$(grep --color=always -Ern 'http[^s]' $TARGETDIR /dev/null)
echo -e "[${green}+${normal}] Lines containg http links."
echo -en "${yellow}--------------------------------------------------------------------------------------------------------------------------------------------------------------${normal}\n"
# echo -e $http_links | sed 's/^/    /'
while read -r line; do
    if [[ "$(echo $line | sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g")" != *"http://schemas.android.com/apk/res/android"* ]] && [[ "$(echo $line | sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g")" != *"import org.apache.http."* ]]\
    && [[ "$(echo $line | sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g")" != *"Lorg/apache/http/"* ]];then
        echo "$line"
    fi
done <<< "$http_links"
# READ CONFIG FILE AND GO THROUGH THE KEYWORDS
while IFS= read -r var
do
    if [[ $var ==  "key" ]];then
        key_words=$(grep --color=always --include="*.java" -irn 'key' $TARGETDIR /dev/null)
        key_words="$key_words\n$(grep --color=always --include="*.xml" -irn 'key' $TARGETDIR /dev/null)"
        echo -e "\n[${green}+${normal}] Lines containg keyword: \"${green}key${normal}\" (excluding keywords \"KeyEvent\" \"keyEvent\" \"containsKey\" \"keyDispatcherState\" \"OnKeyListener\" \"getKey()\" \"keySet()\" \"java.security.KeyStore\").\n"
        echo -en "${yellow}--------------------------------------------------------------------------------------------------------------------------------------------------------------${normal}\n"
        while read -r line; do
            if [[ "$(echo $line | sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g")" != *"KeyEvent"* ]] && [[ "$(echo $line | sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g")" != *"keyEvent"* ]]\
            && [[ "$(echo $line | sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g")" != *"containsKey"* ]] && [[ "$(echo $line | sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g")" != *"keyDispatcherState"* ]]\
            && [[ "$(echo $line | sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g")" != *"OnKeyListener"* ]] && [[ "$(echo $line | sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g")" != *'getKey()'* ]] \
            && [[ "$(echo $line | sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g")" != *'keySet()'* ]] && [[ "$(echo $line | sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g")" != *'java.security.KeyStore'* ]] \
            && [[ "$(echo $line | sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g")" != *'KeyData keyData = new KeyData();'* ]] && [[ "$(echo $line | sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g")" != *'hasPermanentMenuKey()'* ]] \
            && [[ "$(echo $line | sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g")" != *'keyboard'* ]] && [[ "$(echo $line | sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g")" != *'keyData.meta['* ]] \
            && [[ "$(echo $line | sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g")" != *'KeyCharacterMap'* ]];then
                echo "$line"
            fi
        done <<< "$key_words"
    else
        key_words=$(grep --color=always --include="*.java" -irn "$var" $TARGETDIR /dev/null)
        key_words="$key_words\n$(grep --color=always --include="*.xml" -irn "$var" $TARGETDIR /dev/null)"
        echo -e "\n[${green}+${normal}] Lines containg keyword: \"${green}$var${normal}\"."
        echo -en "${yellow}--------------------------------------------------------------------------------------------------------------------------------------------------------------${normal}\n"
        while read -r line; do
            echo "$line"
        done <<< "$key_words"
    fi
done < "$CONFIG"
