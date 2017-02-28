#!/usr/bin/env bash

unlock()
{
    if [[ -z $(adb shell dumpsys power | grep mHoldingDisplaySuspendBlocker=true) ]];then
        adb shell input keyevent 26
    fi
    adb shell input swipe 560 1840 560 1250 100
    adb shell input text 'XXXX' #INPUT YOUR PIN HERE
    adb shell input keyevent 66
    if [[ -z $(adb shell dumpsys power | grep nl.syntaxa.caffeine.service.CaffeineService) ]];then
        adb shell am start -a android.intent.action.MAIN -n nl.syntaxa.caffeine/.preference.activity.PreferenceActivity  > /dev/null 2>&1
        if [[ -z $(adb shell dumpsys activity | grep nl.syntaxa.caffeine/.service.CaffeineService) ]];then
            adb shell input tap 940 309
        fi
        adb shell input tap 975 860
        adb shell input keyevent 4
    fi
}
spinner()
{
    local pid=$1
    local delay=0.75
    local spinstr='|/-\'
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}


unlock &
spinner $!
