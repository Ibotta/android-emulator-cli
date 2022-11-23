#!/bin/bash

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

# Intro END
########################################################
# CPU Detection START

CPU_ARCH=$(arch)
CPU_ABI=""
if [[ $CPU_ARCH == "arm64" ]]; then 
	CPU_ABI="arm64-v8a";
else
	CPU_ABI="x86_64";
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

yes | ~/Library/Android/sdk/cmdline-tools/latest/bin/sdkmanager platform-tools emulator

echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo ""
echo ""
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"

sleep .5
echo "Getting Recommended Android API"

ANDROID_API=$(~/Library/Android/sdk/cmdline-tools/latest/bin/sdkmanager --list --channel=0 | grep -o 'platforms;android-[0-9][0-9]' | awk -F"android-" '/android-/{ print $2}' | tail -2 | head -1)

echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo ""
echo ""
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"

sleep .5

echo "Downloading Android API $ANDROID_API files."
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"

yes | ~/Library/Android/sdk/cmdline-tools/latest/bin/sdkmanager "platforms;android-$ANDROID_API"

echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo ""
echo ""
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"

sleep .5

echo "Downloading an Android API $ANDROID_API System Imag for $CPU_ABI."
SYSTEM_IMAGE="system-images;android-$ANDROID_API;google_apis_playstore;$CPU_ABI"
yes | ~/Library/Android/sdk/cmdline-tools/latest/bin/sdkmanager $SYSTEM_IMAGE

echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo ""
echo ""
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"

sleep .5

echo "Downloading Android Platform Tools and Emulator files."

BUILD_TOOLS=$(~/Library/Android/sdk/cmdline-tools/latest/bin/sdkmanager --list | grep "build-tools"  | tail -1 | cut -f1 -d'|' | sed 's: ::g' )

echo "Build tools found: $BUILD_TOOLS"
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"

yes | ~/Library/Android/sdk/cmdline-tools/latest/bin/sdkmanager "$BUILD_TOOLS"

echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo ""
echo ""
echo "Updating emulator files"
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"

yes | ~/Library/Android/sdk/cmdline-tools/latest/bin/sdkmanager --update

echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo ""

sleep .5

echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
# Need to accept licenses for any installed packages 
# https://developer.android.com/studio/command-line/sdkmanager#accept-licenses
# If already accepted, then will skip.
echo "Checking if any Licenses need to be accepted"
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"

yes | ~/Library/Android/sdk/cmdline-tools/latest/bin/sdkmanager --licenses

echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo ""

sleep .5

# SDKManager Platform-Tools & Emulator END
########################################################
# Android Emulator creation & launch START

echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo; echo;
EMULATOR_NAME="PixelXL_"$ANDROID_API"_"$CPU_ABI""
echo "Creating a new Android Emulator called $EMULATOR_NAME."
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"

echo "no" | ~/Library/Android/sdk/cmdline-tools/latest/bin/avdmanager create avd -n $EMULATOR_NAME -d "pixel_xl" -k $SYSTEM_IMAGE --force

echo ""
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "Setting emulator hardware settings."
echo ""

sleep .5

echo ""
echo "no" | ~/Library/Android/sdk/cmdline-tools/latest/bin/avdmanager create avd -n ${EMULATOR_NAME} -d "pixel_xl" -k ${SYSTEM_IMAGE} --force
 
sleep 2

# Need to evaluate this path to set a skin
SKIN_PATH=~/Library/Android/sdk/skins/pixel_2_xl
SKIN_PATH_VAL="skin.path = ${SKIN_PATH}"
SKIN_IMAGE_SYSDIR="image.sysdir.1 = ${SYSTEM_IMAGE}"
{
	echo 'fastboot.forceFastBoot = yes'
	echo 'hw.camera.back = virtualscene'
	echo 'hw.camera.front = emulated'
	echo 'hw.cpu.ncore = 4'
	echo 'hw.gpu.enabled = yes'
	echo 'hw.gpu.mode = auto'
	echo 'hw.initialOrientation = Portrait'
	echo 'hw.keyboard = yes'
	echo $SKIN_PATH_VAL
} >> ~/.android/avd/${EMULATOR_NAME}.avd/config.ini

echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "Launching your fresh new emulator!"
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"

yes | ~/Library/Android/sdk/emulator/emulator -avd "${EMULATOR_NAME}" &

# Android Emulator creation & launch END
########################################################
# EOF