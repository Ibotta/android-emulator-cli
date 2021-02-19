#!/bin/bash
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

# Command line tools used to be here
FILE1=~/Library/Android/sdk/tools/bin/sdkmanager
# But now they should reside here
FILE2=~/Library/Android/sdk/cmdline-tools/latest/bin/sdkmanager
# if [ -f "$FILE1" ]; then
	# echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
	# echo "Android CLI Tools already installed, moving on."
	# echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
# el

if [ -f "$FILE2" ]; then
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
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "Ensuring that you are updated to the latest version."
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "Downloading Android Platform Tools and Emulator files."
yes | ~/Library/Android/sdk/cmdline-tools/latest/bin/sdkmanager platform-tools emulator
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo ""
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "Downloading Android API 29 files."
yes | ~/Library/Android/sdk/cmdline-tools/latest/bin/sdkmanager "platforms;android-29"
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo ""
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "Downloading an Android API 29 System Image."
yes | ~/Library/Android/sdk/cmdline-tools/latest/bin/sdkmanager "system-images;android-29;google_apis_playstore;x86_64"
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo ""
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "Downloading Android Platform Tools and Emulator files."
yes | ~/Library/Android/sdk/cmdline-tools/latest/bin/sdkmanager "build-tools;29.0.3"
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo ""
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo ""
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "Updating emulator files"
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
yes | ~/Library/Android/sdk/cmdline-tools/latest/bin/sdkmanager --update
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "Creating a new Android Emulator."
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "no" | ~/Library/Android/sdk/cmdline-tools/latest/bin/avdmanager create avd -n PixelXL29 -d "pixel_xl" -k "system-images;android-29;google_apis_playstore;x86_64"
echo ""
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "Setting emulator hardware settings."
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"

# Need to evaluate this path to set a skin
SKIN_PATH=~/Library/Android/sdk/skins/pixel_2_xl
SKIN_PATH_VAL="skin.path = $SKIN_PATH"
{
	echo 'fastboot.forceFastBoot = yes'
	echo 'hw.camera.back = webcam0'
	echo 'hw.camera.front = webcam0'
	echo 'hw.cpu.ncore = 4'
	echo 'hw.gpu.enabled = yes'
	echo 'hw.gpu.mode = auto'
	echo 'hw.initialOrientation = Portrait'
	echo 'hw.keyboard = yes'
	echo $SKIN_PATH_VAL
} >> ~/.android/avd/PixelXL29.avd/config.ini

echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "Launching your fresh new emulator!"
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
yes | ~/Library/Android/sdk/tools/emulator -avd PixelXL29 &
