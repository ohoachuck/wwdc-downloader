WWDC 2015, 2014, 2013 & Tech-talks 2013 <br/>Videos and sessions PDFs downloader
================


This script is a bash script that should **work out of the box** without any needs of extra software or development package.
** **

Its main purpose is to let you bulk download all WWDC **videos** and **PDF** session presentations in one shot.
Current script version does support **WWDC 2015**, WWDC 2014, WWDC 2013 and Tech Talk 2013.

Please note that **2015 sessions** does come with associated **sample codes**.

Using options, you can choose to retrieve HD or SD videos and set destination folder (default is SD).

__Storage size required for 2015 resources:__

* HD videos: 126 GB
* SD videos: 33 GB
* Sample codes: 600 MB
* PDFs: 262 MB


If for some reason you do not have downloaded all in one shot, the script will resume where you left off and does not download again everything. 

The spirit of the script is to be working on everybody's Mac environment without need of special tools. That's why it is based on curl (vs wget).

Note: I know the script name is crap, but believe me, if you knew me you'll know that it could have been even worse ... :).

Also, I know this script use far too much lines of code. But this was just for me a playground in playing around with Bash. Then I kept going like this since WWDC 2013. Don't blame me ;( - I'm a marketing guy.

### Usage
`wwdcVideoPDFGet-curlVersion.sh`

does download by default WWDC 2015 SD videos sessions.

### Options
You can try `wwdcVideoPDFGet-curlVersion.sh -h` for more options.

Usage: 	wwdcVideoPDFGet-curlVersion.sh [options]

Options:

		-y <year>: select year (ex: -y 2013). Default year is 2015. 
			Possible values for year: 2013, 2014 or 2015
			For info: year 2012 videos download is not yet available - to be honest, I'm too lazy to do it!
		-e <event>: select event type between "wwdc" and "tech-talks"
			default value is "wwdc"
		-f <format>: select video format type (SD or HD). Default video format is SD
		-s <comma separated session numbers>: select which sessions you want to download (try option -L for list of sessions)
		-v : verbose mode
		-o <output path>: path where to download content (default is /Users/oho/Documents/WWDC-<selected year|default=2015>)
		-l <iTunes login>: Give your Developer portal login (so far you don't need to login anymore (Apple bug?). If this does change, please use -l option).
		-L: list of video sessions available


Most common usage:

		- Download all SD videos for wwdc 2015:
			wwdcVideoPDFGet-curlVersion.sh

Other examples:

		- Download all HD videos for wwdc 2015:
			wwdcVideoPDFGet-curlVersion.sh -f HD
		- Download only session 201, 400 and 401 with SD videos for wwdc 2015:
			wwdcVideoPDFGet-curlVersion.sh -s 201,400,401
		- Download only session 201 and 400 with HD video for wwdc 2015:
			wwdcVideoPDFGet-curlVersion.sh -s 201,400 -f HD
		- Download all HD videos for wwdc 2015 in /<PATH>/WWDC-2015 using verbose mode:
			wwdcVideoPDFGet-curlVersion.sh -v -f HD -o /<PATH>/WWDC-2015 
		

### Add-ons
**[Not updated]** If you have Alfred 2, there is a workflow to search for sessions by title name or alternatively search in session speach transcription with [asciiwwdc.com](http://asciiwwdc.com).


### Requirements
Works on MAC OS X.

Should also work on Linux systems (as long as you change output directory): never tested!

### Related content
You might want to discover the great **WWDC mac app** from Guilherme Rambo:  https://github.com/insidegui/WWDC
