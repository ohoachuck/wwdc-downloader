WWDC 2014, 2013 & Tech-talks 2013 <br/>Videos and sessions PDFs downloader
================

*****
LAST MINUTE INFO:

1) USING YOUR DEVELOPER PORTAL LOGIN IS NO MORE NEEDED SO FAR TO DOWNLOAD WWDC 2014 SESSION CONTENT

2) WWDC 2013 HD VIDEOS ARE SO FAR NO MORE AVAILABLE FROM APPLE DEV PORTAL
*****


This script is a bash script that should **work out of the box** without any needs of extra software or development package.

Its main purpose is to let you bulk download all WWDC videos and session presentations (pdf) in one shot.
Current script version does support **WWDC 2014**, WWDC 2013 and Tech Talk 2013.
Using options, you can choose to retrieve HD or SD videos and set destination folder.

Video resources and PDFs for 2013 take about 52GB of disk space for HD videos (half of it for SD). For WWDC 2014 it is so far around 30Go HD videos (this might increase a bit as this note is written 2 days after the sessions are finished. Some more videos might be uploaded later). So if for some reason you do not have downloaded it in one shot, the script will resume where you left off and does not download again everything. 

The spirit of the script is to be working on everybody's Mac environment without need of special tools. That's why it is based on curl (vs wget).

So far login/password are not needed anymore, but if given using -l option, password will not displayed on the screen nor store locally. It is used to login within Apple developer portal using **https** as you would do from the web (you can check it in code).

Note: I know the script name is crap, but believe me, if you knew me you'll know that it could have been even worse ... :)

### Usage
`wwdcVideoPDFGet-curlVersion.sh`

WWDC 2014 SD videos + pdf sessions will be downloaded by default.

### Options
You can try `wwdcVideoPDFGet-curlVersion.sh -h` for more options.

Usage: 	wwdcVideoPDFGet-curlVersion.sh [options]

Options:

		-y <year>: select year (ex: -y 2013). Default year is 2014. 
			Possible values for year: 2013 or 2014
			For info: year 2012 videos download is not yet available - to be honest, I'm too lazy to do it!
		-e <event>: select event type between "wwdc" and "tech-talks"
			default value is "wwdc"
		-f <format>: select video format type (SD or HD). Default video format is SD
		-s <comma separated session numbers>: select which sessions you want to download
		-v : verbose mode
		-o <output path>: path where to download content (default is /Users/oho/Documents/WWDC-<selected year|default=2014>)
		-l <iTunes login>: Give your Developer portal login (so far you don't need to login anymore (Apple bug?). If this does change, please use -l option).


Most common usage:

		- Download all PDFs and SD videos for wwdc 2014:
			wwdcVideoPDFGet-curlVersion.sh

Other examples:

		- Download all PDFs and SD videos for wwdc 2014 if Apple change his mind and ask for login:
			wwdcVideoPDFGet-curlVersion.sh -l john.doe@me.com
		- Download all PDFs and SD videos for tech-talks 2013:
			wwdcVideoPDFGet-curlVersion.sh -y 2013 -e tech-talks -l john.doe@me.com
		- Download all PDFs and HD videos for wwdc 2014:
			wwdcVideoPDFGet-curlVersion.sh -f HD -l john.doe@me.com
		- Download only session 201, 400 and 401 with SD videos for wwdc 2014:
			wwdcVideoPDFGet-curlVersion.sh -s 201,400,401 -l john.doe@me.com
		- Download only session 201 and 400 with HD video for wwdc 2014:
			wwdcVideoPDFGet-curlVersion.sh -s 201,400 -f HD -l john.doe@me.com
		- Download all PDFs and HD videos for wwdc 2014 in /Users/oho/Documents/WWDC-2014 using verbose mode:
			wwdcVideoPDFGet-curlVersion.sh -v -f HD -o /Users/oho/Documents/WWDC-2014 -l john.doe@me.com
		

More information on http://blog.hoachuck.biz/blog/2014/06/06/script-to-download-wwdc-2014-videos/

### Add-ons
If you have Alfred 2, there is a workflow to search for sessions by title name or alternatively search in session speach transcription with [asciiwwdc.com](http://asciiwwdc.com).


### Requirements
Works on MAC OS X.

Should also work on Linux systems (as long as you change output directory): never tested!

