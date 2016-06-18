WWDC 2016 Video sessions bulk download (wwdc2016.swift)
================

Note: the previous **wwdcVideoPDFGet-curlVersion.sh** bas beed deprecated (see [previous readme](https://github.com/ohoachuck/wwdc-downloader/blob/master/DEPRECATED-README.md))

**wwdc2016.swift** script is a Swift script that should **work out of the box** without any needs of extra software or development package.
** **

Its main purpose is to let you bulk download all WWDC **videos** session presentations in one shot.
Current script version only supports **WWDC 2016**.

So far the script is basic and does not come with as many options as the previous deprecated script. Indeed Apple have changed its Video locations.

As the point of this script is to play with code for a marketing guy, I decided this time to play with Swift (My first time coding in Swift) and copy/paste some Google pieces of codes together. Hopefully this help downloads in one shot all sessions for take away.

Using the options below, you can choose to retrieve HD or SD videos.

Warning: script will download videos in the current directory.

### Usage
`wwdc2016.swift`

downloads by default WWDC 2016 HD videos sessions.

### Options
You can try `wwdc2016.swift -h` for more options.

Usage: 	wwdc2016.swift [--hd] [--sd] [--help]

Examples:

		- Download all SD videos for wwdc 2016:
			wwdc2016.swift --sd
		
### Requirements
Works on macOS.


### Related content
You might want to discover the great **WWDC Mac app** from Guilherme Rambo:  https://github.com/insidegui/WWDC
