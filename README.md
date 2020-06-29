# Android Emulator CLI

Welcome to the Android Emulator CLI tool! This tool allows you to easily spin up an Android emulator without needing to install Android Studio. It wraps all the necessary Android CLI binaries in a script to do the hard work for you! 

### What it downloads, installs, and configures:
* Android CLI Tools 
* JDK8
* Android Emulator Tools
* Android Platform Tools
* Android Build Tools
* Android Platform (Currently API 29)
* Android System Images (Currently API 29)
* Configures an API 29 emulator and launches it!

### Usage
1. Open a terminal on your computer
2. Copy and paste this command into your terminal and hit enter! 

    ```
    curl -s https://ibotta.github.io/android-emulator-cli/android_emulator_cli.sh | bash
    ```

###### note: Current support for Mac OS and Linux only.