#!/usr/bin/env bash

adb forward tcp:31415 tcp:31415;
drozer console connect 2> /tmp/drozer_start_error
ERROR=$(</tmp/drozer_start_error)
if [[ -z $ERROR ]];then
    echo asss
    exit 0
elif [[ "$ERROR" == *"Connection reset"* ]];then
    adb shell am start -a android.intent.action.MAIN -n com.mwr.dz/.activities.MainActivity > /dev/null 2>&1
    adb shell input keyevent 4
    drozer console connect 2> /tmp/drozer_start_error
    ERROR=$(</tmp/drozer_start_error)
    if [[ -z $ERROR ]];then
        exit 0
    else
        adb shell am start -a android.intent.action.MAIN -n com.mwr.dz/.activities.MainActivity > /dev/null 2>&1
        if [[ -z $(adb shell dumpsys power | grep mHoldingDisplaySuspendBlocker=true) ]];then
            echo -e "[+] Unlock Phone and try again"
            exit 1
        fi
        adb shell input tap 922 1730
        adb shell input keyevent 4
        drozer console connect
    fi
fi
