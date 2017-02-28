#!/usr/bin/env bash
red='\e[31m'
yellow='\e[33m'
green="\e[32m"
blue='\e[34m'
gray='\033[1;30m'
white='\033[1;37m'
normal=$(tput sgr0)


http_links=$(grep --color=always -Ern 'http[^s]' $1 /dev/null)
echo -e "[${green}+${normal}] Lines containg http links."
echo -en "${yellow}--------------------------------------------------------------------------------------------------------------------------------------------------------------${normal}\n"
# echo -e $http_links | sed 's/^/    /'
while read -r line; do
    if [[ "$(echo $line | sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g")" != *"http://schemas.android.com/apk/res/android"* ]] && [[ "$(echo $line | sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g")" != *"import org.apache.http."* ]]\
    && [[ "$(echo $line | sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g")" != *"Lorg/apache/http/"* ]];then
        echo "$line"
    fi
done <<< "$http_links"

# password
key_words=$(grep --color=always --include="*.java" -irn 'password' $1 /dev/null)
key_words="$key_words\n$(grep --color=always --include="*.xml" -irn 'password' $1 /dev/null)"
echo -e "\n[${green}+${normal}] Lines containg keyword: \"${green}password${normal}\"."
echo -en "${yellow}--------------------------------------------------------------------------------------------------------------------------------------------------------------${normal}\n"
while read -r line; do
    echo "$line"
done <<< "$key_words"

# token
key_words=$(grep --color=always --include="*.java" -irn 'token' $1 /dev/null)
key_words="$key_words\n$(grep --color=always --include="*.xml" -irn 'token' $1 /dev/null)"
echo -e "\n[${green}+${normal}] Lines containg keyword: \"${green}token${normal}\"."
echo -en "${yellow}--------------------------------------------------------------------------------------------------------------------------------------------------------------${normal}\n"
while read -r line; do
    echo "$line"
done <<< "$key_words"

# salt
key_words=$(grep --color=always --include="*.java" -irn 'salt' $1 /dev/null)
key_words="$key_words\n$(grep --color=always --include="*.xml" -irn 'salt' $1 /dev/null)"
echo -e "\n[${green}+${normal}] Lines containg keyword: \"${green}salt${normal}\"."
echo -en "${yellow}--------------------------------------------------------------------------------------------------------------------------------------------------------------${normal}\n"
while read -r line; do
    echo "$line"
done <<< "$key_words"
# key
key_words=$(grep --color=always --include="*.java" -irn 'key' $1 /dev/null)
key_words="$key_words\n$(grep --color=always --include="*.xml" -irn 'key' $1 /dev/null)"
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

# admin
key_words=$(grep --color=always --include="*.java" -irn 'admin' $1 /dev/null)
key_words="$key_words\n$(grep --color=always --include="*.xml" -irn 'admin' $1 /dev/null)"
echo -e "\n[${green}+${normal}] Lines containg keyword: \"${green}admin${normal}\"."
echo -en "${yellow}--------------------------------------------------------------------------------------------------------------------------------------------------------------${normal}\n"
echo -e $key_words

# md5
key_words=$(grep --color=always --include="*.java" -irn 'md5' $1 /dev/null)
key_words="$key_words\n$(grep --color=always --include="*.xml" -irn 'md5' $1 /dev/null)"
echo -e "\n[${green}+${normal}] Lines containg keyword: \"${green}md5${normal}\"."
echo -en "${yellow}--------------------------------------------------------------------------------------------------------------------------------------------------------------${normal}\n"
echo -e $key_words

# sha256
key_words=$(grep --color=always --include="*.java" -irn 'sha256' $1 /dev/null)
key_words="$key_words\n$(grep --color=always --include="*.xml" -irn 'sha256' $1 /dev/null)"
echo -e "\n[${green}+${normal}] Lines containg keyword: \"${green}sha256${normal}\"."
echo -en "${yellow}--------------------------------------------------------------------------------------------------------------------------------------------------------------${normal}\n"
echo -e $key_words