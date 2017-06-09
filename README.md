WWDC 2017 Video sessions bulk download (wwdc2017.swift)
================

Note: the previous **wwdcVideoPDFGet-curlVersion.sh** has been deprecated (see [previous readme](https://github.com/ohoachuck/wwdc-downloader/blob/master/DEPRECATED-README.md))

**wwdc2017.swift** script is a Swift script that should **work out of the box** without any needs of extra software or development package.
** **

Its main purpose is to let you bulk download all WWDC session **videos** and **pdf resources** in one shot.
Current script version only supports **WWDC 2017**. You can use previous **wwdc2016.swif** for 2016 video sessions.

So far the script is basic and does not come with as many options as the previous deprecated script (wwdcVideoPDFGet-curlVersion.sh).

Ok, this script is not the best in class solution to get WWDC videos and other resources. It was mainly created for 2 purposes: (1) play and explore with Swift scripting - for the Marketing guy I am - and (2) have a mean to bulk download in an exernal drive the all videos in one shot while benefiting from WWDC conf center fast internet connection.

Using the options below, you can choose to retrieve HD or SD videos and whether to download the pdf resource as well.

Note: script will download videos/pdfs in the current directory.

### Usage
`./wwdc2017.swift`

downloads by default WWDC 2017 HD videos sessions.

### Options
You can try `wwdc2017.swift --help` for more options.

Usage: 	wwdc2017.swift [--hd] [--sd] [--pdf] [--pdf-only] [--sessions <s1 s2 ...>] [--list-only] [--help]

Examples:

		- Download all SD videos for wwdc 2017:
			./wwdc2017.swift --sd
			
		- Download all SD videos & the slides PDF for wwdc 2017:
			./wwdc2017.swift --sd --pdf
		
		- Download only all PDF for wwdc 2017:
			./wwdc2017.swift --pdf-only

		- Download only SD videos + PDFs for sessions 503 and 504 for wwdc 2017:
			./wwdc2017.swift --sd --pdf --sessions 503 504

		- List titles of known sessions for wwdc 2017:
			./wwdc2017.swift --list-only

### Requirements
Works on macOS.


### Related content
You might want to discover the great **WWDC Mac app** from Guilherme Rambo:  https://github.com/insidegui/WWDC
