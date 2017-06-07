WWDC 2017 Video sessions bulk download (wwdc2017.swift)
================

Note: the previous **wwdcVideoPDFGet-curlVersion.sh** has been deprecated (see [previous readme](https://github.com/ohoachuck/wwdc-downloader/blob/master/DEPRECATED-README.md))

**wwdc2017.swift** script is a Swift script that should **work out of the box** without any needs of extra software or development package.
** **

Its main purpose is to let you bulk download all WWDC session **videos** and **pdf resources** in one shot.
Current script version only supports **WWDC 2017**.

So far the script is basic and does not come with as many options as the previous deprecated script. Indeed Apple have changed its Video locations.

As the point of this script is to play with code for a marketing guy, I decided this time to play with Swift (My first time coding in Swift) and copy/paste some Google pieces of codes together. Hopefully this help downloads in one shot all sessions for take away.

Using the options below, you can choose to retrieve HD or SD videos and whether to download the pdf resource as well.

Note: script will download videos/pdfs in the current directory.

### Usage
`./wwdc2017.swift`

downloads by default WWDC 2017 HD videos sessions.

### Options
You can try `wwdc2016.swift --help` for more options.

Usage: 	wwdc2017.swift [--hd] [--sd] [--pdf] [--pdf-only] [--sessions <s1 s2 ...>] [--help]

Examples:

		- Download all SD videos for wwdc 2017:
			./wwdc2017.swift --sd
			
		- Download all SD videos & the slides PDF for wwdc 2017:
			./wwdc2017.swift --sd --pdf
		
		- Download only all PDF for wwdc 2017:
			./wwdc2017.swift --pdf-only

		- Download only SD videos + PDFs for sessions 503 and 504 for wwdc 2017:
			./wwdc2017.swift --sd --pdf --sessions 503 504

### Requirements
Works on macOS.


### Related content
You might want to discover the great **WWDC Mac app** from Guilherme Rambo:  https://github.com/insidegui/WWDC
