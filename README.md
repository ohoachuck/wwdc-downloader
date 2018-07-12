WWDC 2018 Video sessions bulk download (wwdc2018.swift)
================


**wwdc2018.swift** script is a Swift script that should **work out of the box** without any needs of extra software or development package.
** **

Its main purpose is to let you bulk download all WWDC session **videos**, **pdf resources** and **sample codes** in one shot.

Latest version is **wwdc2018.swift**, but you might want to use previous years versions.

Ok, this script is not the best in class solution for getting WWDC videos and other resources. There are multiple version of scripts that does the same out there. But the best in class reference is the nice designed mac application done by [Guilherme Rambo](https://github.com/insidegui) : [WWDC](https://github.com/insidegui/WWDC). You definitely want to check he's [website](https://wwdc.io).

The current scripts was mainly created to get in one shot all videos at the end of DubDubDC right before you run back home (in an external hard drive for instance). It's a good move to take benefice of WWDC conference center fast cable connection.

Using the options below, you can choose to retrieve 1080p, 720p or SD videos and request to download pdf and sample codes as well.

Note: script will download videos/pdfs in the current directory.

#### 1080p videos
Downloading 1080p videos requires video processing. The script will attempt to use `ffmpeg` if available but will fallback to using macOS included `avconvert`. `avconvert` included with macOS don't seem to support copy mode and would force the video to be re-encoded. It will take significantly longer to process. You are encouraged to [install ffmpeg] (http://brewformulas.org/Ffmpeg) if you are donwloading the 1080p videos. 

### Usage
`./wwdc2018.swift`

downloads by default WWDC 2018 HD videos sessions.

### Options
You can try `wwdc2018.swift --help` for more options.

Usage: 	wwdc2018.swift [--hd1080] [--hd] [--sd] [--pdf] [--pdf-only] [--sample] [--sample-only] [--sessions <s1 s2 ...>] [--list-only] [--help]

Examples:

		- Download all 1080p videos for wwdc 2018:
			./wwdc2018.swift --hd1080
			
		- Download all SD videos for wwdc 2018:
			./wwdc2018.swift --sd
			
		- Download all SD videos & the slides PDF for wwdc 2018:
			./wwdc2018.swift --sd --pdf

		- Download all SD videos, slides PDF & the sample code for wwdc 2018:
			./wwdc2018.swift --sd --pdf --sample
		
		- Download only all PDF for wwdc 2018:
			./wwdc2018.swift --pdf-only
		
		- Download only all sample code for wwdc 2018:
			./wwdc2018.swift --sample-only

		- Download only SD videos + PDFs for sessions 503 and 504 for wwdc 2018:
			./wwdc2018.swift --sd --pdf --sessions 503 504

		- List titles of known sessions for wwdc 2018:
			./wwdc2018.swift --list-only

### Requirements
Works on macOS.


### Related content
Note: the previous **wwdcVideoPDFGet-curlVersion.sh** has been deprecated (see [previous readme](https://github.com/ohoachuck/wwdc-downloader/blob/master/DEPRECATED-README.md))
