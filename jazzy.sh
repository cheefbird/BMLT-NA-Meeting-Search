#!/bin/sh
CWD="$(pwd)"
MY_SCRIPT_PATH=`dirname "${BASH_SOURCE[0]}"`
cd "${MY_SCRIPT_PATH}"
rm -drf docs
jazzy   --github_url https://github.com/bmlt-enabled/BMLT-NA-Meeting-Search\
        --readme ./README.md --theme fullwidth\
        --author Little\ Green\ Viper\ Software\ Development\ LLC\
        --author_url https://littlegreenviper.com\
        --min-acl private\
        --exclude */Carthage
cp icon.png docs/icon.png
cp img/*.* docs/img/
cd "${CWD}"
