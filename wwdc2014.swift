#!/usr/bin/swift -swift-version 4

/*
	Author: Olivier HO-A-CHUCK
	Date: June 17th 2016
	About this script:
 WWDC 2016 is ending today and even if there are some great tools out there (https://github.com/insidegui/WWDC) that allow to see and download video sessions,
 I Still need to get my video doggy bag to fly back home. And Moscone alsways provide with great bandwidth.
 So as I had never really started to code in Swift I decided to start here (I know it's late - but I'm no more a developer) and copy/pasted some internet peace
 of codes to get a Swift Script that bulk download all sessions.
 You may have understand my usual disclamer : "I'm a Marketing guy" so don't blame my messy (Swift beginer) code.
 Please feel free to make this script better if you feel like so. There is plenty to do.
	
	License: Do what you want with it. But notice that this script comes with no warranty and will not be maintained.
	Usage: wwdc2016.swift
	Default behavior: without any options the script will download all available hd videos. And will re-take non fully downloaded ones.
	Please use --help option to get currently available options
 
	TODO:
 - basically all previous script option (previuous years, checks, cleaner code, etc.)
 
 */

import Cocoa

enum VideoQuality: String {
  case HD = "hd"
  case SD = "sd"
}

class wwdcVideosController {
    
    class func getHDorSDdURLsFromStringAndFormat(_ testStr: String, format: VideoQuality) -> (String) {
        let pat = "\\b.*(http.*_" + format.rawValue + "[_.].*\\.{0,1}mov)\\b"
        let regex = try! NSRegularExpression(pattern: pat, options: [])
        let matches = regex.matches(in: testStr, options: [], range: NSRange(location: 0, length: testStr.count))
        var videoURL = ""
        if !matches.isEmpty {
            let range = matches[0].range(at: 1)
            let r = testStr.index(testStr.startIndex, offsetBy: range.location) ..<
                    testStr.index(testStr.startIndex, offsetBy: range.location+range.length)
            videoURL = String(testStr[r])
        }
        
        return videoURL
    }
    
    class func getPDFResourceURLFromString(_ testStr: String) -> (String) {
        let pat = "\\b.*(http.*\\.pdf)\\b"
        let regex = try! NSRegularExpression(pattern: pat, options: [])
        let matches = regex.matches(in: testStr, options: [], range: NSRange(location: 0, length: testStr.count))
        var pdfResourceURL = ""
        if !matches.isEmpty {
            let range = matches[0].range(at: 1)
            let r = testStr.index(testStr.startIndex, offsetBy: range.location) ..<
                    testStr.index(testStr.startIndex, offsetBy: range.location+range.length)
            pdfResourceURL = String(testStr[r])
        }
        
        return pdfResourceURL
    }
    
    class func getStringContentFromURL(_ wwdcUrl: String) -> (String) {
        guard let url = URL(string: wwdcUrl) else {
            return ""
        }

        var result = ""
        do {
            let data = try Data(contentsOf: url)
            result = String(data: data, encoding: .ascii)!
            
        } catch let error {
            print("URL Session Task Failed: %@", error.localizedDescription)
        }

        return result
    }
    
    class func getSessionsListFromString(_ htmlSessionList: String) -> Array<String> {
        let pat = "/videos/play/wwdc2014/([0-9]*)/\">"
        let regex = try! NSRegularExpression(pattern: pat, options: [])
        let matches = regex.matches(in: htmlSessionList, options: [], range: NSRange(location: 0, length: htmlSessionList.count))
        var sessionsListArray = [String]()
        for match in matches {
            for n in 0..<match.numberOfRanges {
                let range = match.range(at: n)
                let r = htmlSessionList.index(htmlSessionList.startIndex, offsetBy: range.location) ..<
                        htmlSessionList.index(htmlSessionList.startIndex, offsetBy: range.location+range.length)
                switch n {
                case 1:
                    //print(htmlSessionList.substringWithRange(r))
                    sessionsListArray.append(String(htmlSessionList[r]))
                default: break
                }
            }
        }
        return sessionsListArray
    }

    class func system(_ command: String) {
        var args = command.components(separatedBy: " ")
        let path = args.first
        args.remove(at: 0)

        let task = Process()
        task.launchPath = path
        task.arguments = args
        task.launch()
        task.waitUntilExit()
    }

    class func downloadFileFromURLString(_ urlString: String, forSession session: String = "???") {
        let fileName = URL(fileURLWithPath: urlString).lastPathComponent
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: "./" + fileName) {
            print("\(fileName): already exists, nothing to do!")
        } else {
            print("[Session \(session)] Getting \(fileName) (\(urlString)):")
            let cmd = "/usr/bin/curl \(urlString) -o ./\(fileName).download"
            system(cmd)
            
            print("moving ./\(fileName).download to ./\(fileName)")
            do {
                try fileManager.moveItem(atPath: "./\(fileName).download", toPath: "./\(fileName)")
            }
            catch let error as NSError {
                print("Ooops! Something went wrong: \(error)")
            }
            print("Done!")
        }
    }
}

/* Managing options */
var format = VideoQuality.HD
var shouldDownloadPDFResource = false
var shouldDownloadVideoResource = true

for argument in CommandLine.arguments {
 switch argument {
	case "-h", "--help":
        print("wwdc2016 - a simple swifty video sessions bulk download.\nJust Get'em all!")
        print("usage: wwdc2006.swift [--hd] [--sd] [--pdf] [--pdf-only] [--help]\n")
        exit(0)

	case "--hd":
		print("Downloading HD videos in current directory")
		format = .HD

	case "--sd":
		print("Downloading SD videos in current directory")
		format = .SD
    
    case "--pdf":
        shouldDownloadPDFResource = true
    
    case "--pdf-only":
        shouldDownloadPDFResource = true
        shouldDownloadVideoResource = false

	default:
		break
	}
}

func sortFunc(value1: String, value2: String) -> Bool {
    
    let filteredVal1 = String(value1[..<value1.index(value1.startIndex, offsetBy:3)])
    let filteredVal2 = String(value2[..<value2.index(value2.startIndex, offsetBy:3)])
    
    return filteredVal1 < filteredVal2;
}


/* Retreiving list of all video session */
let htmlSessionListString = wwdcVideosController.getStringContentFromURL("https://developer.apple.com/videos/wwdc2014/")
print("Let me ask Apple about currently available sessions. This can take some time (15 to 20 sec.) ...")
var sessionsListArray = wwdcVideosController.getSessionsListFromString(htmlSessionListString)
sessionsListArray.sort(by: sortFunc)

/* getting individual videos */
for (_, value) in sessionsListArray.enumerated() {
    let baseURL = "https://developer.apple.com/videos/play/wwdc2014/" + value + "/"
    let htmlText = wwdcVideosController.getStringContentFromURL(baseURL)
	if shouldDownloadVideoResource {
	    let videoURLString = wwdcVideosController.getHDorSDdURLsFromStringAndFormat(htmlText, format: format)
	    if videoURLString.isEmpty {
	        print("[Session \(baseURL)] NO VIDEO YET AVAILABLE !!!")
            exit(0)
	    } else {
	        wwdcVideosController.downloadFileFromURLString(videoURLString, forSession: value)
	    }
	}
    
    if shouldDownloadPDFResource {
        let pdfResourceURLString = wwdcVideosController.getPDFResourceURLFromString(htmlText)
        if pdfResourceURLString.isEmpty {
            print("[Session \(value)] PDF RESOURCE NOT (YET?) AVAILABLE !!!")
        } else {
            wwdcVideosController.downloadFileFromURLString(pdfResourceURLString, forSession: value)
        }
    }
}
