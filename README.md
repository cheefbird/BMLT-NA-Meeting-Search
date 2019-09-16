# BMLT NA Meeting Search iOS App #

This is a comprehensive meeting search app for iPhone and iPad, based on [the BMLTiOSLib iOS Framework](https://bmlt.magshare.net/specific-topics/bmltioslib/).

Yes, the damn repo is labeled "NA Meeting Finder." That's my fault. "Search" is more comprehensive, so the final app will be called "NA meeting Search" (If the Powers That be will it).

It is provided by [the BMLT developers](https://bmlt.magshare.net).

It uses [the worldwide version](https://tomato.na-bmlt.org/main_server/) of [the Root Server](https://bmlt.app/installing-a-new-root-server/) to locate meetings, using [the BMLTiOSLib iOS Framework](https://bmlt.magshare.net/specific-topics/bmltioslib/).

### This Repository Is 100% of the Source Code for This Project ###

[This is the repository for this project.](https://github.com/bmlt-enabled/BMLT-NA-Meeting-Search)

* Like all [BMLT](https://bmlt.app)  projects, this is a completely open-source project. There is no hidden or proprietary code anywhere.

### Setup ###

* This is an [Apple Xcode](https://developer.apple.com/xcode/) project, using [Swift](https://developer.apple.com/swift/) language, version 5. It requires Xcode Version 10, at minimum.
* The project requires [the BMLTiOSLib iOS Framework](https://bmlt.app/specific-topics/bmltioslib/).
* This will require that the user have iOS version 11.0 or greater.

### License ###

This is a [GPL V.3](https://gnu.org) project.

This is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

BMLT is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See [the GNU General Public License](https://www.gnu.org/licenses/licenses.html#GPL) for more details.

## CHANGELIST ##

***Version 1.2.0.3001* ** *- September 16, 2019*

- No changes. Apple wants me to resubmit with the newest RC of Xcode.

***Version 1.2.0.3000* ** *- September 15, 2019*

- Minor internal "code smell" fix.
- Made a few special cases for iOS 13, where the segmented switches needed some styling.
- App Store release candidate.

***Version 1.2.0.2000* ** *- August 24, 2019*

- Switched the BMLTiOSLib to use Carthage.
- Updated to latest Swift and Xcode versions.
- The project now requires iOS 11.
- Updated to the latest version of Swift.
- Removed the Swipeable Tab Bar Controller. It broked the latest release, and, quite frankly, wasn't worth it.
- Improved the appearance of the launch screen.
- Improved the behavior of the layout on X-phones.
- Improved documentation for 100% Jazzy docs.
- Switched to the MIT License.
- Fixed a small bug, where changing the map type while the "AUTO" switch was off (distance circle overlay shown) would not be redrawn after changing the map type.

***Version 1.1.2.2002* ** *- December 28, 2018*

- Updated to the latest BMLTiOSLib
- Added Danish localization
- Fixed a minor issue with Italian localization.
- Updated to Swift 4.2 and latest Xcode support.

***Version 1.1.1.3000* ** *- April 3, 2018*

- No changes. Release to App Store.

***Version 1.1.1.2006* ** *- April 2, 2018*

- Added an "invisible" parameter to the server calls, so that TOMATO will know that its being called by BMLTiOSLib apps.
- Updated to Xcode 9.3/Swift 4.1

***Version 1.1.1.2005* ** *- March 17, 2018*

- Fixed an issue where we expect Saturday to come before Sunday in the Today search.

***Version 1.1.1.2004* ** *- March 17, 2018*

- No changes. iTunes Connect had a meltdown, and I had to re-up the build.

***Version 1.1.1.2003* ** *- March 16, 2018*

- Italian tweak.

***Version 1.1.1.2002* ** *- March 15, 2018*

- Italian tweak.

***Version 1.1.1.2001* ** *- March 13, 2018*

- Fixed an issue where a communication error could result in an alert loop.

***Version 1.1.1.2000* ** *- March 13, 2018*

- Adds the new "Tomato" server.

***Version 1.1.0.3000* ** *- February 12, 2018*

- App Store Release.

***Version 1.1.0.2010* ** *- February 1, 2018*

- Had the wrong translation file in the app. That has been corrected.

***Version 1.1.0.2009* ** *- February 1, 2018*

- Complete Italian Translation.

***Version 1.1.0.2008* ** *- February 1, 2018*

- Partial Italian Translation.

***Version 1.1.0.2007* ** *- January 31, 2018*

- Added Italian location files for testing.
- Fixed a bug, where the weekday displayed in the details page was different from the one displayed in the list for areas where the week starts on Monday.

***Version 1.1.0.2006* ** *- January 30, 2018*

- Added a placeholder for Italian localization (It has not yet actually been localized).

***Version 1.1.0.2005* ** *- January 26, 2018*

- If you do a search from the Location/Map screen, the initial results tab is the map. The other two result in list results as the initial screen.

***Version 1.1.0.2004* ** *- January 19, 2018*

- The map results now show the user location.

***Version 1.1.0.2003* ** *- January 7, 2018*

- Updated to the latest version of the BMLTiOSLib pod.
- Tweaked the sort for weeks that start on days other than Monday.

***Version 1.1.0.2002* ** *- January 7, 2018*

- Updated to the latest version of the BMLTiOSLib pod.
- Added the Reveal Framework.
- Added initial Swedish localization.

***Version 1.1.0.2001* ** *- December 13, 2017*

- Updated to the latest version of the BMLTiOSLib pod.

***Version 1.1.0.2000* ** *- December 12, 2017*

- Added the BMLTiOSLib and Swipeable Tab Bar Controller as CocoaPods, as well as SwiftLint, and cleaned up the code as per SwiftLint.

***Version 1.0.0.3000* ** *- September 21, 2017*

- First App Store Release

***Version 1.0.0.2006* ** *- September 19, 2017*

- Made the label for the "Use Google Maps" switch shrink its text size if necessary.

***Version 1.0.0.2005* ** *- September 19, 2017*

- Fairly significant UI changes. Made the backgrounds dark blue, enhanced the contrast on the Tab Bar and made the buttons look more like "buttons."

***Version 1.0.0.2001* ** *- September 15, 2017*

- Fixes a crash that can occur if a long search is in progress.

***Version 1.0.0.2000* ** *- September 13, 2017*

- First Beta release.

