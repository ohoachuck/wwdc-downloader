/!\ Whatch out: current script does not work if you try to download directly to an external Hard Drvie !

WWDC Video sessions bulk download (wwdcDownloader.swift)
================
I went to the WWDC Debug lab and found out that current script does not work with shebang (#!/usr/bin/swift) due to a bug in Swift 5.1 (I will file a radar).

So the workaround (waiting for Swift 5.1 bug fix) is to compile the script before runing it (no crash with swiftc).

Synthax: `wwdcDownloader.sh <same params as describes bellow>`

example: `wwdcDownloader.sh --hd720 --pdf --sample` (will download all files in the same folder)

** **

**wwdcDownloader.swift** script is a Swift script that should **work out of the box** without any needs of extra software or development package (at least ususaly :) ).


Its main purpose is to let you bulk download all WWDC session **videos**, **pdf resources** and **sample codes** in one shot.

Latest version is **wwdcDownloader.swift**.

Ok, this script is not the best in class solution for getting WWDC videos and other resources. There are multiple version of scripts that does the same out there. But the best in class reference is the nice designed mac application done by [Guilherme Rambo](https://github.com/insidegui) : [WWDC](https://github.com/insidegui/WWDC). You definitely want to check he's [website](https://wwdc.io).

The current scripts was mainly created to get in one shot all videos at the end of DubDubDC right before you run back home (in an external hard drive for instance). It's a good move to take advantage of WWDC conference center fast cable connection.

Using the options below, you can choose to retrieve 1080p, 720p or SD videos and request to download pdf and sample codes as well.

Note: script will download videos/pdfs in the current directory.

#### 1080p videos
Downloading 1080p videos requires video processing. The script will attempt to use `ffmpeg` if available otherwise, will download the stream files but will not convert. The conversion process can be started after all videos are downloaded. After installing `ffmpeg`, re-running `wwdcDownloader` the same way as the first time will only convert the downloaded stream files to video files. You can install `ffmpeg` via  [Homebrew (ffmpeg)] (https://formulae.brew.sh/formula/ffmpeg) (brew install ffmpeg) if you are downloading the 1080p videos. 

### Usage
`./wwdcDownloader.swift`

Downloads by default WWDC 2019 HD 1080p videos sessions (need ffmpeg).

Unless you plan to watch the videos on your TV you might just want to do get HD versions (720p):

`./wwdcDownloader.swift --hd720 --pdf --sample`

for taking HD videos, PDFs and sample codes when available.

### Options
You can try `wwdcDownloader.swift --help` for more options.

Usage: 	wwdcDownloader.swift [--wwdc-year &lt;year&gt;] [--tech-talks] [--hd1080] [--hd720] [--sd] [--pdf] [--pdf-only] [--sample] [--sample-only] [--sessions &lt;s1 s2 ...&gt;] [--list-only] [--help]

Examples:

		- Download all 1080p videos for wwdc 2019 (default):
			./wwdcDownloader.swift --hd1080
			
		- Download all HD (720p) videos, slides PDF & the sample codes for wwdc 2019:
			./wwdcDownloader.swift --hd720 --pdf --sample

		- Download all 720p videos for wwdc 2019:
			./wwdcDownloader.swift --hd720
			
		- Download all SD videos for wwdc 2019:
			./wwdcDownloader.swift --sd
			
		- Download all SD videos & the slides PDF for wwdc 2019:
			./wwdcDownloader.swift --sd --pdf

		- Download all SD videos, slides PDF & the sample code for wwdc 2019:
			./wwdcDownloader.swift --sd --pdf --sample
		
		- Download only all PDF for wwdc 2019:
			./wwdcDownloader.swift --pdf-only
		
		- Download only all sample code for wwdc 2019:
			./wwdcDownloader.swift --sample-only

		- Download only SD videos + PDFs for sessions 503 and 504 for wwdc 2019:
			./wwdcDownloader.swift --sd --pdf --sessions 503 504

		- List titles of known sessions for wwdc 2019:
			./wwdcDownloader.swift --list-only

		- Download all 1080p videos for wwdc 2019:
			./wwdcDownloader.swift --wwdc-year 2019

### Requirements
* Works on macOS.
* ffmpeg (for 1080 HD videos).

### Related content
[WWDC](https://github.com/insidegui/WWDC) native app done by [Guilherme Rambo](https://github.com/insidegui). You definitely want to check his [website](https://wwdc.io).
