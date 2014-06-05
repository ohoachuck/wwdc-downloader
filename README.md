WWDC 2014, 2013 & Tech-talks 2013

Videos and sessions PDFs downloader
================

This script is a bash script that should **work out of the box** without any needs of extra software or development package.

It's main purpose is to let you (as an Apple registered developer) bulk download all WWDC videos and session presentations (pdf) in one shot.
Current script version does support **WWDC 2014**, WWDC 2013 and Tech Talk 2013.
Using options, you can choose to retrieve HD or SD videos and set destination folder.

Video resources and PDFs for 2013 take about 52GB of disk space for HD videos (half of it for SD), so if for some reason you do not have downloaded it in one shot, the script take it back when it have been stopped and does not download again everything. I still have to figure out how big will be WWDC 2014 sessions (not yet closed when I'm writing this).

The spirit of the script is to be working on everybody's mac environment without need of special tools. That's why it is based on curl (vs wget).

Your password is not displayed on the screen nor store locally. It is used to login within Apple developer portal using **https** as you would do from the web (you can see it in ligne 54 or line 229).

Note: I know the script name is crap, but believe me, if you knew me you'll know that it could have been even worse ... :)

### Usage
`wwdcVideoPDFGet-curlVersion.sh <Apple Developer account login>`

You will be prompted for your Apple Developer password then WWDC 2014 SD videos + pdf sessions will be downloaded by default.

### Options
You can try `wwdcVideoPDFGet-curlVersion.sh -h` for more options.

Usage: 	wwdcVideoPDFGet-curlVersion.sh [options] <Apple dev login>

Options:

		-y <year>: select year (ex: -y 2013). Default year is 2014
		Possible values for year: 2013 or 2014
		For info: year 2012 videos download is not yet available - to be honest, I'm too lazy to do it!
		-e <event>: select event type between "wwdc" and "tech-talks"
		default value is "wwdc"
		-f <format>: select video format type (SD or HD). Default video format is SD
		-s <comma separated session numbers>: select which sessions you want to download
		-v : verbose mode
		-o <output path>: path where to download content (default is /Users/<your user>/Documents/WWDC-<selected year|default=2014>)


Most common usage:

		- Download all PDFs and SD videos for wwdc 2014:
			wwdcVideoPDFGet-curlVersion.sh john.doe@me.com

Other examples:

		- Download all PDFs and SD videos for tech-talks 2013:
			wwdcVideoPDFGet-curlVersion.sh -y 2013 -e tech-talks john.doe@me.com
		- Download all PDFs and HD videos for wwdc 2014:
			wwdcVideoPDFGet-curlVersion.sh -f HD john.doe@me.com
		- Download only session 201, 400 and 401 with SD videos for wwdc 2014:
			wwdcVideoPDFGet-curlVersion.sh -s 201,400,401 john.doe@me.com
		- 	Download only session 201 and 400 with HD video for wwdc 2014:
			wwdcVideoPDFGet-curlVersion.sh -s 201,400 -f HD john.doe@me.com
		- Download all PDFs and HD videos for wwdc 2014 in /Users/<your user>/Documents/WWDC-2014 using verbose mode:
			wwdcVideoPDFGet-curlVersion.sh -v -f HD -o /Users/<your user>/Documents/WWDC-2014 john.doe@me.com
		

More information on http://blog.hoachuck.biz/blog/2013/06/15/script-to-download-wwdc-2013-videos/

### Add-ons
If you have Alfred 2, there is a workflow to search for sessions by title name or alternatively search in session speach transcription with asciwwdc.com.


### Requirements
Works on MAC OS X.

Should be working on Linux systems (as long as you change output directory): never tested!

