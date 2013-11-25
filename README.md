WWDC Video and PDF downloader
================

This script is a bash script that should work out of the box without any needs of extra software or development package.

Its main purpose is to login into your Apple Developer account and retrieve all videos and associated documentation into a local folder arbitrary created on your Desktop (Mac OS architecture).
Video resources (SD) and PDF take about 52GB of disk space, so if for some reason you couldn't download it in one shot, the script resumes where it has stopped and does not download everything again.

### Usage
`wwdcDownloader.sh <Apple Developer account login>`

You will be prompted for your Apple Developer password. And SD videos will be downloaded by default.

### Options
You can try `wwdcDownloader.sh -h` for more options.

This second script allows you to choose between SD and HD videos to download. But also would let you choose for instance to get only some specific sessions instead of all videos.

See what's `wwdcDownloader.sh -h` option currently say:

		Usage: 	wwdcDownloader.sh [options] <Apple dev login>
		Options:
			-y <year>: select year (ex: -y 2012). Default year is 2013
				Possible values for year: 2012, 2013, all
				Warning: year 2012 videos download is not yet available
			-f <format>: select video format type (SD or HD). Default video format is SD
			-s <comma separated session numbers>: select which sessions you want to download
			-v : verbose mode
			-o <output path>: path where to download content (default is /Users/${USER}/Desktop/WWDC-2013)
			
		Examples:
			- Download all PDFs and SD videos for 2013:
  				wwdcDownloader.sh john.doe@me.com
			- Download all PDFs and HD videos for 2013:
  				wwdcDownloader.sh -f HD john.doe@me.com
			- Download only session 201, 400 and 401 with SD videos for 2013:
  				wwdcDownloader.sh -s 201,400,401 john.doe@me.com
			- Download only session 201 and 400 with HD video for 2013:
  				wwdcDownloader.sh -s 201,400 -f HD john.doe@me.com
			- Download all PDFs and HD videos for 2013 in /Users/oho/Documents/WWDC-SESSIONS using verbose mode:
  				wwdcDownloader.sh -v -f HD -o /Users/oho/Documents/WWDC-SESSIONS john.doe@me.com
		

More information on http://blog.hoachuck.biz/blog/2013/06/15/script-to-download-wwdc-2013-videos/

### Requirements
Works on Mac OS X.

Should be working on Linux systems (as long as you change output directory): never tested!

