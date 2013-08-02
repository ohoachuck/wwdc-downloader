WWDC Video and PDF downloder
================

This script is a bash script that should work out of the box without any needs of extra software or development package.

It's main purpose is to login into your Apple developer account and retreive all videos and associated documentations into a local folder arbitrary created on your Desktop (mac os architecture).
Video resources taken (SD) and PDF take about 52GB of disk space, so if for some reason you do not have downloaded it in one shot, the script take it back when it have been stoped and does not download again averything.

There are 2 versions for the same script:

1. `wwdcVideoPDFGet.sh` => initial version based on wget (**depreciated!**)
2. `wwdcVideoPDFGet-curlVersion.sh` => adapted version based on curl (no need for wget)

First version is not updated anymore because it does not comply with current rule which is "script should work out of the box"! Indeed wget is not standard in most mac OS X versions. Please use `wwdcVideoPDFGet-curlVersion.sh` instead (I know the script name is crap). This second script is the only one being updated and improved so far.

### Usage
`wwdcVideoPDFGet-curlVersion.sh <Apple Developer account login>`

You will be prompted for your Apple Developer password. And SD videos will be downloaded by default.

### Options
You can try `wwdcVideoPDFGet-curlVersion.sh -h` for more options. This second script allow you to choose for SD vs HD videos format to download.

For downloading HD videos:

 - `wwdcVideoPDFGet-curlVersion.sh -f HD <Apple Developer account login>`
		

More information on http://blog.hoachuck.biz/blog/2013/06/15/script-to-download-wwdc-2013-videos/

### Requirements
Work on MAC OS X.
Should be easily adapted for any Linux system.

