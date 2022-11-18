#!/bin/bash



#~/Library/Android/sdk/cmdline-tools/latest/bin/sdkmanager --list --channel=0 | awk '{ print $NF,$0|"sort -n -k1" }' | grep 'Android SDK Platform.*' | tail -2 | head -1
#~/Library/Android/sdk/cmdline-tools/latest/bin/sdkmanager --list --channel=0 | grep 'Android SDK Platform.*' | awk '{ print $NF,$0|"sort -n -k1" }' | tail -2 | head -1
# Get's second latest API version (In case we don't yet support the latest API)
#~/Library/Android/sdk/cmdline-tools/latest/bin/sdkmanager --list --channel=0 | grep -o 'platforms;android-[0-9][0-9]' | awk -F"android-" '/android-/{ print $2}' | tail -2 | head -1


########################################################
# Intro START
echo
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo
echo "              \\"
echo "               \\"
echo "                \\\\"
echo "                 \\\\"
echo "                  >\\/7"
echo "              _.-(6'  \\"
echo "             (=___._/\` \\"
echo "                  )  \\ |"
echo "                 /   / |"
echo "                /    > /"
echo "               j    < _\\"
echo "           _.-' :      ``."
echo "           \\ r=._\\        \`."
echo "          <\`\\\\_  \\         .\`-."
echo "           \\ r-7  \`-. ._  ' .  \`\\"
echo "            \\\`,      \`-.\`7  7)   )"
echo "             \\/         \\|  \\'  / \`-._"
echo "                        ||    .'"
echo "Android                  \\\\  ("
echo "Emulator                  >\\  >"
echo "  CLI                 ,.-' >.'"
echo "                     <.'_.''"
echo "                       <'"

echo; echo;

echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "Welcome to the Android Emulator CLI only script!"
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
sleep .5

# Intro END
########################################################
# Main Menu START

# PS3='Please enter your choice'
# options=""


# Main Menu END
########################################################
# CPU Detection START

CPU_ABI=$(arch)
# CPU_NAME=$(sysctl -n machdep.cpu.brand_string)
if [[ "$CPU_ABI" == "arm64" ]]; then 
	CPU_ABI="arm64-v8a";
elif [[ "$CPU_ABI" == "i386" ]] | [[ "$CPU_API" == "x86_64" ]]; then
	CPU_ABI="x86_64";
else
	echo "ERROR: No recognizable CPU / ABI was found. Cannont continue with installation.";
	exit;
fi
echo "** CPU Found: $CPU_ABI **"
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"

# CPU Detection END
########################################################
# Java START

echo "** Checking for already installed files **"
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "Checking for current JDK versions"
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"

wait
JAVA_VERSION=$(java -version 2>&1 | awk '/version/{print $NF}')
# Is Java 8 Installed?
if echo $JAVA_VERSION | grep -q 1.8; then
	echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
	echo "Java 1.8 is installed, good to go!"
	echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
else 
	echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
	echo "Java 1.8 not installed, let's install it."
	echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
	# Awesome SDK manager 
	curl -s "https://get.sdkman.io" | bash
	source ~/.sdkman/bin/sdkman-init.sh
	# Install JDK -- More info on versions here: https://bit.ly/2SCGEnb
	JDK_8_VERSION=$(sdk list java | grep -o "8\.0\.[0-9][0-9][0-9]\.hs\-adpt")
	sdk install java $JDK_8_VERSION
	echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
	echo "Java 8 successfully installed!"
	echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
fi

# Java END
########################################################
# Android CLI Tools START

# Command line tools used to have another location but now resides here.
FILE1=~/Library/Android/sdk/cmdline-tools/latest/bin/sdkmanager

if [ -f "$FILE1" ]; then
	echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
	echo "Android CLI Tools already installed, moving on."
	echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
else
	echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
	echo "Android CLI Tools not found."
	echo "Downloading Android Command Line Tools."
	echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
	echo "Unzipping Android Command Line Tools..........."
	LATEST_CLI_TOOLS_URL=$(curl https://developer.android.com/studio | grep -o "https:\/\/dl.google.com\/android\/repository\/commandlinetools\-mac\-[0-9]*_latest\.zip")
	cd /tmp && { curl -O $LATEST_CLI_TOOLS_URL ; cd -; }
	echo "Moving CLI tools to /Library/Android"
	unzip /tmp/commandlinetools* -d /tmp
	mkdir -p ~/Library/Android/sdk/cmdline-tools/latest
	mv /tmp/cmdline-tools/* ~/Library/Android/sdk/cmdline-tools/latest
	echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
	echo "Adding Android Tools to PATH."
	echo "export ANDROID_SDK_ROOT=~/Library/Android/sdk" >> ~/.bash_profile
	echo "export ANDROID_HOME=~/Library/Android/sdk" >> ~/.bash_profile
fi

export ANDROID_SDK_ROOT=~/Library/Android/sdk
export ANDROID_HOME=~/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin/

# Android CLI Tools END
########################################################
# SDKManager Platform-Tools & Emulator START

echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "Ensuring that you are updated to the latest version."
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "Downloading Android Platform Tools and Emulator files."
wait
~/Library/Android/sdk/cmdline-tools/latest/bin/sdkmanager platform-tools emulator
wait
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo ""
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo ""
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"

sleep .5
echo "Getting Recommended Android API"
ANDROID_API=$(~/Library/Android/sdk/cmdline-tools/latest/bin/sdkmanager --list --channel=0 | grep -o 'platforms;android-[0-9][0-9]' | awk -F"android-" '/android-/{ print $2}' | tail -2 | head -1)
wait
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo ""
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo ""
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"

sleep .5
echo "Downloading Android API $ANDROID_API files."
wait
~/Library/Android/sdk/cmdline-tools/latest/bin/sdkmanager "platforms;android-$ANDROID_API"
wait
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo ""
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo ""
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"

sleep .5
echo "Downloading an Android API $ANDROID_API System Image."
~/Library/Android/sdk/cmdline-tools/latest/bin/sdkmanager "system-images;android-$ANDROID_API;google_apis_playstore;$CPU_ABI"
sleep 10
wait
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo ""
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo ""
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"

sleep .5

echo "Downloading Android Platform Tools and Emulator files."
wait
BUILD_TOOLS=$(~/Library/Android/sdk/cmdline-tools/latest/bin/sdkmanager --list | grep "build-tools"  | tail -1 | cut -f1 -d'|' | sed 's: ::g' )
wait
echo "Build tools found: $BUILD_TOOLS"
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
~/Library/Android/sdk/cmdline-tools/latest/bin/sdkmanager "$BUILD_TOOLS"
wait
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo ""
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo ""
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "Updating emulator files"
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
wait
yes | ~/Library/Android/sdk/cmdline-tools/latest/bin/sdkmanager --update
wait
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo ""

sleep .5

echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
# Need to accept licenses for any installed packages 
# https://developer.android.com/studio/command-line/sdkmanager#accept-licenses
# If already accepted, then will skip.
echo "Checking if any Licenses need to be accepted"
wait
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
yes | ~/Library/Android/sdk/cmdline-tools/latest/bin/sdkmanager --licenses
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo ""

sleep .5

# SDKManager Platform-Tools & Emulator END
########################################################
# Android Emulator creation & launch START

echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "Creating a new Android Emulator."
wait
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "no" | ~/Library/Android/sdk/cmdline-tools/latest/bin/avdmanager create avd -n PixelXL29 -d "pixel_xl" -k "system-images;android-$ANDROID_API;google_apis_playstore;$CPU_ABI" --force
echo ""
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "Setting emulator hardware settings."
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"

sleep .5


# Need to evaluate this path to set a skin
SKIN_PATH=~/Library/Android/sdk/skins/pixel_2_xl
SKIN_PATH_VAL="skin.path = $SKIN_PATH"
{
	echo 'fastboot.forceFastBoot = yes'
	echo 'hw.camera.back = virtualscene'
	echo 'hw.camera.front = emulated'
	echo 'hw.cpu.ncore = 4'
	echo 'hw.gpu.enabled = yes'
	echo 'hw.gpu.mode = auto'
	echo 'hw.initialOrientation = Portrait'
	echo 'hw.keyboard = yes'
	echo "image.sysdir.1=system-images/android-$ANDROID_API/google_apis_playstore/$CPU_ABI/"
	echo $SKIN_PATH_VAL
} >> ~/.android/avd/PixelXL29.avd/config.ini

echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "Launching your fresh new emulator!"
wait
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
yes | ~/Library/Android/sdk/emulator/emulator -avd PixelXL29 &

# Android Emulator creation & launch END
########################################################
# EOF