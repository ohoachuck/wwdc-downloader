WWDC Video and PDF downloder
================

This script is a bash script that should work out of the box without any needs of extra software or development package.
It's main purpose is to login into your Apple developer account and retreive all videos and associated documentations into a local folder arbitrary created on your Desktop (mac os architecture).
Video resources taken (SD) and PDF take about 3 Go of disk space, so if for some reason you do not have downloaded it in one shot, the script take it back when it have been stoped and does not download again averything.

There is 2 versions for the same script:
1. `wwdcVideoPDFGet.sh` => initial version based on wget
2. `wwdcVideoPDFGet-curlVersion.sh` => adapted version based on curl (no need for wget)

### Usage
`wwdcVideoPDFGet.sh <Apple Developer account login> <Apple developer account password>`
or
`wwdcVideoPDFGet-curlVersion.sh <Apple Developer account login> <Apple developer account password>`

More information on http://blog.hoachuck.biz/blog/2013/06/15/script-to-download-wwdc-2013-videos/

### Requirements
Work on MAC OS X.
Should be easily adapted for any Linux system.

