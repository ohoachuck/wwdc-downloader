/!\ Whatch out: current script does not work if you try to download directly to an external Hard Drvie !

WWDC Video sessions bulk download (Swift Scripts)
================
I went to the WWDC Debug lab and found out that current script does not work with shebang (#!/usr/bin/swift) due to a bug in Swift 5.1 (I will file a radar).

So the workaround (waiting for Swift 5.1 bug fix) is to compile the script before runing it (no crash with swiftc).

Synthax: `wwdcDownloader.sh <same params as describes bellow>`

example: `wwdcDownloader.sh --hd720 --pdf --sample` (will download all files in the same folder)

** **

This repo now ships with two Swift utilities that should **work out of the box** on macOS without extra build steps:

- **wwdc2025.swift** – tuned for the 2025 site structure. It downloads HD/SD MP4s, PDFs, and sample code (via the `book.json` endpoint) without needing `ffmpeg`.
- **wwdcDownloader.swift** – the year-switching downloader. It defaults to WWDC 2025, and you can switch to 2024 or 2023 with `--wwdc-year`. It retains the historical 1080p stream + `ffmpeg` workflow and still supports PDFs/sample code.

Both scripts let you bulk pull WWDC session **videos**, **pdf resources** and **sample codes** in one shot.

Ok, this script is not the best in class solution for getting WWDC videos and other resources. There are multiple version of scripts that does the same out there. But the best in class reference is the nice designed mac application done by [Guilherme Rambo](https://github.com/insidegui) : [WWDC](https://github.com/insidegui/WWDC). You definitely want to check he's [website](https://wwdc.io).

The current scripts was mainly created to get in one shot all videos at the end of DubDubDC right before you run back home (in an external hard drive for instance). It's a good move to take advantage of WWDC conference center fast cable connection.

Using the options below, you can choose to retrieve 1080p (stream + `ffmpeg` merge), 720p or SD videos and request to download pdf and sample codes as well.

Note: script will download videos/pdfs in the current directory.

#### 1080p videos
Downloading 1080p videos requires video processing. The script will attempt to use `ffmpeg` if available otherwise, will download the stream files but will not convert. The conversion process can be started after all videos are downloaded. After installing `ffmpeg`, re-running `wwdcDownloader` the same way as the first time will only convert the downloaded stream files to video files. You can install `ffmpeg` via  [Homebrew (ffmpeg)] (https://formulae.brew.sh/formula/ffmpeg) (brew install ffmpeg) if you are downloading the 1080p videos. 

### Usage
`./wwdc2025.swift`

Downloads the WWDC 2025 catalogue in HD MP4 format. Add `--sd`, `--pdf`, `--sample`, or `--sessions <id ...>` to narrow the assets.

`./wwdcDownloader.swift`

Downloads by default WWDC 2025 HD 1080p sessions (requires `ffmpeg` to mux the HLS stream). Switch to 2024 or 2023 with `--wwdc-year`.

Prefer 720p files? Grab them (with PDFs/sample code when available) via `./wwdcDownloader.swift --hd720 --pdf --sample`.

### Options
You can try `wwdcDownloader.swift --help` for more options.

Usage: 	wwdcDownloader.swift [--wwdc-year &lt;year&gt;] [--tech-talks] [--hd1080] [--hd720] [--sd] [--pdf] [--pdf-only] [--sample] [--sample-only] [--sessions &lt;s1 s2 ...&gt;] [--list-only] [--help]

Supported WWDC years: 2025 (default), 2024, 2023.

Examples:

		- Download all 1080p videos for WWDC 2025 (default):
			./wwdcDownloader.swift --hd1080

		- Download all HD (720p) videos, slides PDF & the sample codes for WWDC 2025:
			./wwdcDownloader.swift --hd720 --pdf --sample

		- Download all 720p videos for WWDC 2024:
			./wwdcDownloader.swift --wwdc-year 2024 --hd720

		- Download all SD videos & the slides PDF for WWDC 2023:
			./wwdcDownloader.swift --wwdc-year 2023 --sd --pdf

		- Download only SD videos + PDFs for sessions 503 and 504 (WWDC 2025):
			./wwdcDownloader.swift --sd --pdf --sessions 503 504

		- List titles of known sessions for WWDC 2024:
			./wwdcDownloader.swift --wwdc-year 2024 --list-only

		- Download SD videos + PDFs for sessions 102 and 309 using the 2025-specific script:
			./wwdc2025.swift --sd --pdf --sessions 102 309

### wwdc2025.swift quick reference
- Targets WWDC 2025 catalogue only (no `--wwdc-year` flag)
- Defaults to HD MP4 downloads; switch to SD with `--sd`
- `--pdf`, `--sample`, and `--sessions <id ...>` mirror the classic script
- Automatically prefixes output files with the session identifier

### wwdcDownloader.swift quick reference
- Supports WWDC years 2025 (default), 2024, 2023 plus Tech Talks mode
- `--hd1080` (HLS + `ffmpeg`), `--hd720`, and `--sd` quality presets
- Combine with `--pdf`, `--sample`, and `--sessions <id ...>` to cherry-pick assets
- Re-running after installing `ffmpeg` will convert any previously downloaded 1080p streams

### Requirements
* Works on macOS.
* ffmpeg (for 1080 HD videos).

### Related content
[WWDC](https://github.com/insidegui/WWDC) native app done by [Guilherme Rambo](https://github.com/insidegui). You definitely want to check he's [website](https://wwdc.io).
