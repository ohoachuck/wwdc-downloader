#!/usr/bin/env xcrun swift

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
import SystemConfiguration

enum VideoQuality: String {
    case HD = "hd"
    case SD = "sd"
}

//http://stackoverflow.com/a/30743763
class Reachability {
    
    class func isConnectedToNetwork() -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(sizeofValue(zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        let defaultRouteReachability = withUnsafePointer(&zeroAddress) {
            SCNetworkReachabilityCreateWithAddress(nil, UnsafePointer($0))
        }
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        return (isReachable && !needsConnection)
    }
    
}

class DownloadSessionManager : NSObject, NSURLSessionDownloadDelegate {
    
    static let sharedInstance = DownloadSessionManager()
    var filePath : String?
    var url: NSURL?
    var resumeData: NSData?
    
    let semaphore = dispatch_semaphore_create(0)
    var session : NSURLSession!
    
    override init() {
        super.init()
        self.resetSession()
    }
    
    func resetSession() {
        self.session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration(), delegate: self, delegateQueue: nil)
    }
    
    func downloadFile(fromURL url: NSURL, toPath path: String) {
        self.filePath = path
        self.url = url
        self.resumeData = nil
        
        let task = session.downloadTaskWithURL(url)
        task.resume()
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
    }
    
    func resumeDownload() {
        //TODO: reset session in appropriate NSURLSessionDelegate function?
        self.resetSession()
        
        if let resumeData = self.resumeData {
            print("resuming file download...")
            let task = session.downloadTaskWithResumeData(resumeData)
            task.resume()
            self.resumeData = nil
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
        } else {
            print("retrying file download...")
            self.downloadFile(fromURL: self.url!, toPath: self.filePath!)
        }
    }
    
    func showProgress(progress: Int, barWidth: Int) {
        print("\r[", terminator: "")
        let pos = Int(Double(barWidth*progress)/100.0)
        for i in 0...barWidth {
            switch(i) {
            case _ where i < pos:
                print("=", terminator:"")
                break
            case pos:
                print(">", terminator:"")
                break
            default:
                print(" ", terminator:"")
                break
            }
        }
        
        print("] \(progress)%", terminator:"")
        fflush(__stdoutp)
    }
    
    //MARK : NSURLSessionDownloadDelegate stuff
    
    func URLSession(session: NSURLSession,
                    downloadTask: NSURLSessionDownloadTask,
                    didWriteData bytesWritten: Int64,
                                 totalBytesWritten: Int64,
                                 totalBytesExpectedToWrite: Int64) {
        showProgress(Int(Double(totalBytesWritten)/Double(totalBytesExpectedToWrite)*100.0), barWidth: 70)
    }
    
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL) {
        defer {
            dispatch_semaphore_signal(semaphore)
        }
        
        print("")
        
        guard let _ = self.filePath else {
            print("No destination path to copy the downloaded file at \(location)")
            return
        }
        
        let fileManager = NSFileManager.defaultManager()
        
        print("moving \(location) to \(self.filePath!)")
        
        do {
            try fileManager.moveItemAtURL(location, toURL: NSURL.fileURLWithPath("\(filePath!)"))
        }
        catch let error as NSError {
            print("Ooops! Something went wrong: \(error)")
        }
    }
    
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        guard let _ = error else {
            //No error. Already handled in URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL)
            return
        }
        
        defer {
            defer {
                dispatch_semaphore_signal(semaphore)
            }
            
            if !Reachability.isConnectedToNetwork() {
                print("Waiting for connection to be restored")
                repeat {
                    sleep(1)
                } while !Reachability.isConnectedToNetwork()
            }
            
            self.resumeDownload()
        }
        
        print("")
        
        print("Ooops! Something went wrong: \(error!.localizedDescription)")
        
        guard let resumeData = error!.userInfo[NSURLSessionDownloadTaskResumeData] as! NSData? else {
            return
        }
        self.resumeData = resumeData
    }
}

class wwdcVideosController {
    class func getHDorSDdURLsFromStringAndFormat(testStr: String, format: VideoQuality) -> (String) {
        let pat = "\\b.*(http[^_].*" + format.rawValue + ".*\\.mp4)\\b"
        let regex = try! NSRegularExpression(pattern: pat, options: [])
        let matches = regex.matchesInString(testStr, options: [], range: NSRange(location: 0, length: testStr.characters.count))
        var videoURL = ""
        if !matches.isEmpty {
            let range = matches[0].rangeAtIndex(1)
            let r = testStr.startIndex.advancedBy(range.location) ..<
                testStr.startIndex.advancedBy(range.location+range.length)
            videoURL = testStr.substringWithRange(r)
        }
        
        return videoURL
    }
    
    class func getPDFResourceURLFromString(testStr: String) -> (String) {
        let pat = "\\b.*(http[^_].*\\.pdf)\\b"
        let regex = try! NSRegularExpression(pattern: pat, options: [])
        let matches = regex.matchesInString(testStr, options: [], range: NSRange(location: 0, length: testStr.characters.count))
        var pdfResourceURL = ""
        if !matches.isEmpty {
            let range = matches[0].rangeAtIndex(1)
            let r = testStr.startIndex.advancedBy(range.location) ..<
                testStr.startIndex.advancedBy(range.location+range.length)
            pdfResourceURL = testStr.substringWithRange(r)
        }
        
        return pdfResourceURL
    }
    
    class func getStringContentFromURL(url: String) -> (String) {
        /* Configure session, choose between:
         * defaultSessionConfiguration
         * ephemeralSessionConfiguration
         * backgroundSessionConfigurationWithIdentifier:
         And set session-wide properties, such as: HTTPAdditionalHeaders,
         HTTPCookieAcceptPolicy, requestCachePolicy or timeoutIntervalForRequest.
         */
        let sessionConfig = NSURLSessionConfiguration.defaultSessionConfiguration()
        
        /* Create session, and optionally set a NSURLSessionDelegate. */
        let session = NSURLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
        
        /* Create the Request:
         My API (2) (GET https://developer.apple.com/videos/play/wwdc2016/201/)
         */
        var result = ""
        guard let URL = NSURL(string: url) else {return result}
        let request = NSMutableURLRequest(URL: URL)
        request.HTTPMethod = "GET"
        
        /* Start a new Task */
        let semaphore = dispatch_semaphore_create(0)
        let task = session.dataTaskWithRequest(request, completionHandler: { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            if (error == nil) {
                /* Success */
                // let statusCode = (response as! NSHTTPURLResponse).statusCode
                // print("URL Session Task Succeeded: HTTP \(statusCode)")
                result = NSString(data: data!, encoding:
                    NSASCIIStringEncoding)! as String
            }
            else {
                /* Failure */
                print("URL Session Task Failed: %@", error!.localizedDescription);
            }
            dispatch_semaphore_signal(semaphore)
        })
        task.resume()
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
        return result
    }
    
    class func getSessionsListFromString(htmlSessionList: String) -> Array<String> {
        let pat = "\\b.*\\/videos\\/play\\/wwdc2016\\/([0-9]*)\\/\"><h5\\b"
        let regex = try! NSRegularExpression(pattern: pat, options: [])
        let matches = regex.matchesInString(htmlSessionList, options: [], range: NSRange(location: 0, length: htmlSessionList.characters.count))
        var sessionsListArray = [String]()
        for match in matches {
            for n in 0..<match.numberOfRanges {
                let range = match.rangeAtIndex(n)
                let r = htmlSessionList.startIndex.advancedBy(range.location) ..<
                    htmlSessionList.startIndex.advancedBy(range.location+range.length)
                switch n {
                case 1:
                    //print(htmlSessionList.substringWithRange(r))
                    sessionsListArray.append(htmlSessionList.substringWithRange(r))
                default: break
                }
            }
        }
        return sessionsListArray
    }
    
    class func downloadFileFromURLString(urlString: String, forSession sessionIdentifier: String = "???") {
        let fileName = NSURL(fileURLWithPath: urlString).lastPathComponent!
        let fileManager = NSFileManager.defaultManager()
        
        guard !fileManager.fileExistsAtPath("./" + fileName) else {
            print("\(fileName): already exists, nothing to do!")
            return
        }
        
        print("[Session \(sessionIdentifier)] Getting \(fileName) (\(urlString)):")
        
        guard let url = NSURL(string: urlString) else {
            print("\(urlString) is not valid URL!")
            return
        }
        
        DownloadSessionManager.sharedInstance.downloadFile(fromURL: url, toPath: "\(fileName)")
    }
}

/* Managing options */
var format = VideoQuality.HD
var shouldDownloadPDFResource = false
var shouldDownloadVideoResource = true

for argument in Process.arguments {
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
    
    let filteredVal1 = value1.substringToIndex(value1.startIndex.advancedBy(3))
    let filteredVal2 = value2.substringToIndex(value2.startIndex.advancedBy(3))
    
    return filteredVal1 < filteredVal2;
}

/* Retreiving list of all video session */
let htmlSessionListString = wwdcVideosController.getStringContentFromURL("https://developer.apple.com/videos/wwdc2016/")
print("Let me ask Apple about currently available sessions. This can take some times (15 to 20 sec.) ...")
var sessionsListArray = wwdcVideosController.getSessionsListFromString(htmlSessionListString)
sessionsListArray.sortInPlace(sortFunc)

/* getting individual videos */

for (index, value) in sessionsListArray.enumerate() {
    let htmlText = wwdcVideosController.getStringContentFromURL("https://developer.apple.com/videos/play/wwdc2016/" + value + "/")
    if shouldDownloadVideoResource {
        let videoURLString = wwdcVideosController.getHDorSDdURLsFromStringAndFormat(htmlText, format: format)
        if videoURLString.isEmpty {
            print("[Session \(value)] NO VIDEO YET AVAILABLE !!!")
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
