# Android-Automation
This is a collection of script I created in order to automate certain tideious and time consuming tasks performed during a Android Penetration Assessment. A description of each script follows.
## apk_prepare.sh
### Requirements
* [apktool](https://ibotpeaches.github.io/Apktool/install/)
* [d2j-jar2dex.sh](https://github.com/ufologist/onekey-decompile-apk/blob/master/onekey-decompile-apk/_tools/dex2jar/d2j-jar2dex.sh) as d2j-jar2dex, simply create symbolic link `ln d2j-jar2dex.sh d2j-jar2dex` inside PATH
* [d2j-dex2jar.sh](https://github.com/ufologist/onekey-decompile-apk/blob/master/onekey-decompile-apk/_tools/dex2jar/d2j-dex2jar.sh) same as above
* [jadx](https://github.com/skylot/jadx#building-from-source)
OPTIONAL
* [adb](https://developer.android.com/studio/command-line/adb.html) Required to install application on connected device.

## adb_screencap.sh
This is a simple script that takes a screenshot of the screen currently displayed on the phone. It stores the screen on the screenshot directory of the Project. To use, please modify it and add your root directories. 
