WWDC 2016 Video sessions bulk download (wwdc2016.swift)
================

Note: previous **wwdcVideoPDFGet-curlVersion.sh** have beed deprecated (see [previous readme](https://github.com/ohoachuck/wwdc-downloader/blob/master/DEPRECATED-README.md))

**wwdc2016.swift** script is a Swift script that should **work out of the box** without any needs of extra software or development package.
** **

Its main purpose is to let you bulk download all WWDC **videos** session presentations in one shot.
Current script version does support only **WWDC 2016**.

So far the script is basic and does not come with as many options as previous script that is currently deprecated. Indeed Apple have changed Video locaions.

As the all point of this script is to play with code for a marketing guy. So I decided this time to play with Swift (My first time coding in Swift) and copy/paste som Google peace of codes together. Hopefully this help downloads in one shot all sessions for take away.

Using options, you can choose to retrieve HD or SD videos.

Warning: script will download videos just at it's current directory.

### Usage
`wwdc2016.swift`

does download by default WWDC 2016 HD videos sessions.

### Options
You can try `wwdc2016.swift -h` for more options.

Usage: 	wwdc2006.swift [--hd] [--sd] [--help]

Examples:

		- Download all SD videos for wwdc 2016:
			wwdc2016.swift -sd
		
### Requirements
Works on MAC OS X.


### Related content
You might want to discover the great **WWDC mac app** from Guilherme Rambo:  https://github.com/insidegui/WWDC
