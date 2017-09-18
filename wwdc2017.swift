#!/usr/bin/swift -swift-version 3

/*
	Author: Olivier HO-A-CHUCK
	Date: June 17th 2017
	About this script:
 WWDC 2017 is ending and even if there are some great tools out there (https://github.com/insidegui/WWDC) that allow to see and download video sessions,
 I Still need to get my video doggy bag to fly back home. And Moscone alsways provide with great bandwidth.
 So as I had never really started to code in Swift I decided to start here (I know it's late - but I'm no more a developer) and copy/pasted some internet peace
 of codes to get a Swift Script that bulk download all sessions.
 You may have understand my usual disclamer : "I'm a Marketing guy" so don't blame my messy (Swift beginer) code.
 Please feel free to make this script better if you feel like so. There is plenty to do.
	
	License: Do what you want with it. But notice that this script comes with no warranty and will not be maintained.
	Usage: wwdc2017.swift
	Default behavior: without any options the script will download all available hd videos. And will re-take non fully downloaded ones.
	Please use --help option to get currently available options
 
	TODO:
 - basically all previous script option (previuous years, checks, cleaner code, etc.)
 
 */

import Cocoa
import Foundation
import SystemConfiguration

enum VideoQuality: String {
    case HD = "hd"
    case SD = "sd"
}

//http://stackoverflow.com/a/30743763

class Reachability {
    class func isConnectedToNetwork() -> Bool {
        guard let flags = getFlags() else { return false }
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        return (isReachable && !needsConnection)
    }
    
    class func getFlags() -> SCNetworkReachabilityFlags? {
        guard let reachability = ipv4Reachability() ?? ipv6Reachability() else {
            return nil
        }
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(reachability, &flags) {
            return nil
        }
        return flags
    }
    
    class func ipv6Reachability() -> SCNetworkReachability? {
        var zeroAddress = sockaddr_in6()
        zeroAddress.sin6_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin6_family = sa_family_t(AF_INET6)
        
        return withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        })
    }
    
    class func ipv4Reachability() -> SCNetworkReachability? {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        return withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        })
    }
}

extension Notification.Name {
    static let flagsChanged = Notification.Name("FlagsChanged")
}

struct Network {
    static var reachability: Reachability?
    enum Status: String, CustomStringConvertible {
        case unreachable, wifi, wwan
        var description: String { return rawValue }
    }
    enum Error: Swift.Error {
        case failedToSetCallout
        case failedToSetDispatchQueue
        case failedToCreateWith(String)
        case failedToInitializeWith(sockaddr_in)
    }
}

class DownloadSessionManager : NSObject, URLSessionDownloadDelegate {
    
    static let sharedInstance = DownloadSessionManager()
    var filePath : String?
    var url: URL?
    var resumeData: Data?
    
    let semaphore = DispatchSemaphore.init(value: 0)
    var session : URLSession!
    
    override init() {
        super.init()
        self.resetSession()
    }
    
    func resetSession() {
        self.session = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: nil)
    }
    
    func downloadFile(fromURL url: URL, toPath path: String) {
        self.filePath = path
        self.url = url
        self.resumeData = nil
        taskStartedAt = Date()
        let task = session.downloadTask(with: url)
        task.resume()
        semaphore.wait()
    }
    
    func resumeDownload() {
        //TODO: reset session in appropriate URLSessionDelegate function?
        self.resetSession()
        
        if let resumeData = self.resumeData {
            print("resuming file download...")
            let task = session.downloadTask(withResumeData: resumeData)
            task.resume()
            self.resumeData = nil
            semaphore.wait()
        } else {
            print("retrying file download...")
            self.downloadFile(fromURL: self.url!, toPath: self.filePath!)
        }
    }
    
  func show(progress: Int, barWidth: Int, speedInK: Int) {
        print("\r[", terminator: "")
        let pos = Int(Double(barWidth*progress)/100.0)
        for i in 0...barWidth {
            switch(i) {
            case _ where i < pos:
                print("🁢", terminator:"")
                break
            case pos:
                print("🁢", terminator:"")
                break
            default:
                print(" ", terminator:"")
                break
            }
        }
        
        print("] \(progress)% \(speedInK)KB/s", terminator:"")
        fflush(__stdoutp)
    }

    var taskStartedAt : Date?
    //MARK : URLSessionDownloadDelegate stuff
    func urlSession(_: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didWriteData bytesWritten: Int64,
                    totalBytesWritten: Int64,
                    totalBytesExpectedToWrite: Int64) {
      let now = Date()
      let timeDownloaded = now.timeIntervalSince(taskStartedAt!)
      let kbs = Int( floor( Float(totalBytesWritten) / 1024.0 / Float(timeDownloaded) ) )
        show(progress: Int(Double(totalBytesWritten)/Double(totalBytesExpectedToWrite)*100.0), barWidth: 70, speedInK: kbs)
    }
    
    func urlSession(_: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        defer {
            semaphore.signal()
        }
        
        print("")
        
        guard let _ = self.filePath else {
            print("No destination path to copy the downloaded file at \(location)")
            return
        }
        
        print("moving \(location) to \(self.filePath!)")
        
        do {
            try FileManager.default.moveItem(at: location, to: URL.init(fileURLWithPath: "\(filePath!)"))
        }
            
        catch let error {
            print("Ooops! Something went wrong: \(error)")
        }
    }
    
    func urlSession(_: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard let error = error else {
            //No error. Already handled in URLSession(session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingToURL location: URL)
            return
        }
        
        defer {
            defer {
                semaphore.signal()
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
        
        print("Ooops! Something went wrong: \(error.localizedDescription)")
        
        guard let resumeData = (error as NSError).userInfo[NSURLSessionDownloadTaskResumeData] as? Data else {
            return
        }
        
        self.resumeData = resumeData
    }
}

class wwdcVideosController {
    class func getHDorSDdURLs(fromHTML: String, format: VideoQuality) -> (String) {
        let pat = "\\b.*(https://.*" + format.rawValue + ".*\\.mp4)\\b"
        let regex = try! NSRegularExpression(pattern: pat, options: [])
        let matches = regex.matches(in: fromHTML, options: [], range: NSRange(location: 0, length: fromHTML.characters.count))
        var videoURL = ""
        if !matches.isEmpty {
            let range = matches[0].rangeAt(1)
            let r = fromHTML.index(fromHTML.startIndex, offsetBy: range.location) ..<
                fromHTML.index(fromHTML.startIndex, offsetBy: range.location+range.length)
            videoURL = fromHTML.substring(with: r)
        }
        
        return videoURL
    }
    
    class func getPDFResourceURL(fromHTML: String) -> (String) {
        let pat = "\\b.*(https://.*\\.pdf)\\b"
        let regex = try! NSRegularExpression(pattern: pat, options: [])
        let matches = regex.matches(in: fromHTML, options: [], range: NSRange(location: 0, length: fromHTML.characters.count))
        var pdfResourceURL = ""
        if !matches.isEmpty {
            let range = matches[0].rangeAt(1)
            let r = fromHTML.index(fromHTML.startIndex, offsetBy: range.location) ..<
                fromHTML.index(fromHTML.startIndex, offsetBy: range.location+range.length)
            pdfResourceURL = fromHTML.substring(with: r)
        }
        
        return pdfResourceURL
    }


    class func getTitle(fromHTML: String) -> (String) {
        let pat = "<h1>(.*)</h1>"
        let regex = try! NSRegularExpression(pattern: pat, options: [])
        let matches = regex.matches(in: fromHTML, options: [], range: NSRange(location: 0, length: fromHTML.characters.count))
        var title = ""
        if !matches.isEmpty {
            let range = matches[0].rangeAt(1)
            let r = fromHTML.index(fromHTML.startIndex, offsetBy: range.location) ..<
                fromHTML.index(fromHTML.startIndex, offsetBy: range.location+range.length)
            title = fromHTML.substring(with: r)
        }

        return title
    }

    class func getSampleCodeURL(fromHTML: String) -> [String] {
        let pat = "\\b.*(href=\".*/content/samplecode/.*\")\\b"
        let regex = try! NSRegularExpression(pattern: pat, options: [])
        let matches = regex.matches(in: fromHTML, options: [], range: NSRange(location: 0, length: fromHTML.characters.count))
        var sampleURLPaths : [String] = []
        for match in matches {
            let range = match.rangeAt(1)
            let r = fromHTML.index(fromHTML.startIndex, offsetBy: range.location) ..<
                fromHTML.index(fromHTML.startIndex, offsetBy: range.location+range.length)
            var path = fromHTML.substring(with: r)

            // Tack on the hostname if it's not already there (some URLs are listed as
            // relative URL while some are fully-qualified).
            let prefixReplacementString: String
            if path.contains("href=\"http") == false {
                prefixReplacementString = "https://developer.apple.com"
            } else {
                prefixReplacementString = ""
            }
            path = path.replacingOccurrences(of: "href=\"", with: prefixReplacementString)

            // Strip target attribute suffix
            path = path.replacingOccurrences(of: "\" target=\"", with: "/")

            sampleURLPaths.append(path)
        }

        var sampleArchivePaths : [String] = []
        for urlPath in sampleURLPaths {
            let jsonText = getStringContent(fromURL: urlPath + "book.json")
            if let data = jsonText.data(using: .utf8) {
                let object = try? JSONSerialization.jsonObject(with: data, options: .allowFragments)
                if let dictionary = object as? NSDictionary {
                    if let relativePath = dictionary["sampleCode"] as? String {
                        sampleArchivePaths.append(urlPath + relativePath)
                    }
                }
            }
        }

        return sampleArchivePaths
    }

    class func getStringContent(fromURL: String) -> (String) {
        /* Configure session, choose between:
         * defaultSessionConfiguration
         * ephemeralSessionConfiguration
         * backgroundSessionConfigurationWithIdentifier:
         And set session-wide properties, such as: HTTPAdditionalHeaders,
         HTTPCookieAcceptPolicy, requestCachePolicy or timeoutIntervalForRequest.
         */
        
        /* Create session, and optionally set a URLSessionDelegate. */
        let session = URLSession(configuration: URLSessionConfiguration.default, delegate: nil, delegateQueue: nil)
        
        /* Create the Request:
         My API (2) (GET https://developer.apple.com/videos/play/wwdc2017/201/)
         https://developer.apple.com/videos/play/wwdc2017/102/
         */
        var result = ""
        guard let URL = URL(string: fromURL) else {return result}
        var request = URLRequest(url: URL)
        request.httpMethod = "GET"
        
        /* Start a new Task */
        let semaphore = DispatchSemaphore.init(value: 0)
        let task = session.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) -> Void in
            if (error == nil) {
                /* Success */
                // let statusCode = (response as! NSHTTPURLResponse).statusCode
                // print("URL Session Task Succeeded: HTTP \(statusCode)")
                result = String.init(data: data!, encoding:
                    .ascii)!
            }
            else {
                /* Failure */
                print("URL Session Task Failed: %@", error!.localizedDescription);
            }
            
            semaphore.signal()
        })
        task.resume()
        semaphore.wait()
        return result
    }
    
    class func getSessionsList(fromHTML: String) -> Array<String> {
        let pat = "\"\\/videos\\/play\\/wwdc2017\\/([0-9]*)\\/\""
        let regex = try! NSRegularExpression(pattern: pat, options: [])
        let matches = regex.matches(in: fromHTML, options: [], range: NSRange(location: 0, length: fromHTML.characters.count))
        var sessionsListArray = [String]()
        for match in matches {
            for n in 0..<match.numberOfRanges {
                let range = match.rangeAt(n)
                let r = fromHTML.index(fromHTML.startIndex, offsetBy: range.location) ..<
                    fromHTML.index(fromHTML.startIndex, offsetBy: range.location+range.length)
                switch n {
                case 1:
                    //print(htmlSessionList.substring(with: r))
                    sessionsListArray.append(fromHTML.substring(with: r))
                default: break
                }
            }
        }
        return sessionsListArray
    }
    
    class func downloadFile(urlString: String, forSession sessionIdentifier: String = "???") {
        var fileName = URL(fileURLWithPath: urlString).lastPathComponent

        if fileName.hasPrefix(sessionIdentifier) == false {
            fileName = "\(sessionIdentifier)_\(fileName)"
        }

        guard !FileManager.default.fileExists(atPath: "./" + fileName) else {
            print("\(fileName): already exists, nothing to do!")
            return
        }
        
        print("[Session \(sessionIdentifier)] Getting \(fileName) (\(urlString)):")
        
        guard let url = URL(string: urlString) else {
            print("<\(urlString)> is not valid URL!")
            return
        }
        
        DownloadSessionManager.sharedInstance.downloadFile(fromURL: url, toPath: "\(fileName)")
    }
}

func showHelpAndExit() {
    print("wwdc2017 - a simple swifty video sessions bulk download.\nJust Get'em all!")
    print("usage: wwdc2017.swift [--hd] [--sd] [--pdf] [--pdf-only] [--sessions] [--sample] [--list-only] [--help]\n")
    exit(0)
}

/* Managing options */
var format = VideoQuality.HD
var shouldDownloadPDFResource = false
var shouldDownloadVideoResource = true
var shouldDownloadSampleCodeResource = false

var gettingSessions = false
var sessionsSet:Set<String> = Set()

var arguments = CommandLine.arguments
arguments.remove(at: 0)

for argument in arguments {
    switch argument {
        
    case "-h", "--help":
        showHelpAndExit()
        break
        
    case "--hd":
        format = .HD
        gettingSessions = false
        
    case "--sd":
        format = .SD
        gettingSessions = false
        
    case "--pdf":
        shouldDownloadPDFResource = true
        gettingSessions = false
        
    case "--pdf-only":
        shouldDownloadPDFResource = true
        shouldDownloadVideoResource = false
        gettingSessions = false

    case "--sample":
        shouldDownloadSampleCodeResource = true
        gettingSessions = false

    case "--sample-only":
        shouldDownloadSampleCodeResource = true
        shouldDownloadVideoResource = false
        gettingSessions = false

    case "--sessions", "-s":
        gettingSessions = true
        break
    
    case "--list-only", "-l":
        shouldDownloadVideoResource = false
        break;

    case _ where Int(argument) != nil:
        if(!gettingSessions) {
            fallthrough
        }
        
        sessionsSet.insert(argument)
        break
        
    default:
        print("\(argument) is not a \(#file) command.\n")
        showHelpAndExit()
    }
}

if(shouldDownloadVideoResource) {
    switch format {
        
    case .HD:
        print("Downloading HD videos in current directory")
        break
        
    case .SD:
        print("Downloading SD videos in current directory")
        break
        
    }
}

func sortFunc(value1: String, value2: String) -> Bool {
    
    let filteredVal1 = value1.substring(to: value1.index(value1.startIndex, offsetBy: 3))
    let filteredVal2 = value2.substring(to: value2.index(value2.startIndex, offsetBy: 3))
    
    return filteredVal1 < filteredVal2;
}

/* Retreiving list of all video session */
let htmlSessionListString = wwdcVideosController.getStringContent(fromURL: "https://developer.apple.com/videos/wwdc2017/")
print("Let me ask Apple about currently available sessions. This can take some time (15 to 20 sec.) ...")
var sessionsListArray = wwdcVideosController.getSessionsList(fromHTML: htmlSessionListString)
//get unique values
sessionsListArray=Array(Set(sessionsListArray))

/* getting individual videos */
if sessionsSet.count != 0 {
    let sessionsListSet = Set(sessionsListArray)
    sessionsListArray = Array(sessionsSet.intersection(sessionsListSet))
}

sessionsListArray.sort(by: sortFunc)

for (_, value) in sessionsListArray.enumerated() {
    let htmlText = wwdcVideosController.getStringContent(fromURL: "https://developer.apple.com/videos/play/wwdc2017/" + value + "/")

    let title = wwdcVideosController.getTitle(fromHTML: htmlText)
    print("\n[Session \(value)] : \(title)")

    if shouldDownloadVideoResource {
        let videoURLString = wwdcVideosController.getHDorSDdURLs(fromHTML: htmlText, format: format)
        if videoURLString.isEmpty {
            print("Video : Video is not yet available !!!")
        } else {
            print("Video : \(videoURLString)")

            wwdcVideosController.downloadFile(urlString: videoURLString, forSession: value)
        }
    }

    if shouldDownloadPDFResource {
        let pdfResourceURLString = wwdcVideosController.getPDFResourceURL(fromHTML: htmlText)
        if pdfResourceURLString.isEmpty {
            print("PDF : PDF is not yet available !!!")
        } else {
            print("PDF : \(pdfResourceURLString)")
            wwdcVideosController.downloadFile(urlString: pdfResourceURLString, forSession: value)
        }
    }

    if shouldDownloadSampleCodeResource {
        let sampleURLPaths = wwdcVideosController.getSampleCodeURL(fromHTML: htmlText)
        if sampleURLPaths.isEmpty {
            print("SampleCode: Resource not yet available !!!")
        } else {
            print("SampleCode: ")
            for path in sampleURLPaths {
                print("\(path)")
                wwdcVideosController.downloadFile(urlString: path, forSession: value)
            }
        }
    }
}
