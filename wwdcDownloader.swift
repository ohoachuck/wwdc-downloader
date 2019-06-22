#!/usr/bin/swift

/*
	Author: Olivier HO-A-CHUCK
	Date: June 17th 2017
	About this script:
 WWDC 2019 is ending and even if there are some great tools out there (https://github.com/insidegui/WWDC) that allow to see and download video sessions,
 I Still need to get my video doggy bag to fly back home. And Moscone alsways provide with great bandwidth.
 So as I had never really started to code in Swift I decided to start here (I know it's late - but I'm no more a developer) and copy/pasted some internet peace
 of codes to get a Swift Script that bulk download all sessions.
 You may have understand my usual disclamer : "I'm a Marketing guy" so don't blame my messy (Swift beginer) code.
 Please feel free to make this script better if you feel like so. There is plenty to do.
	
	License: Do what you want with it. But notice that this script comes with no warranty and will not be maintained.
	Usage: wwdcDownloader.swift
	Default behavior: without any options the script will download all available hd1080 videos. And will re-take non fully downloaded ones.
	Please use --help option to get currently available options
 
	TODO:
 - basically all previous script option (previuous years, checks, cleaner code, etc.)
 
 
 Note: SF Tested with Apple Swift version 4.2.1 (swiftlang-1000.11.42 clang-1000.11.45.1)
 */

import Cocoa
import Foundation
import SystemConfiguration

enum VideoQuality: String {
    case HD1080 = "1080"
    case HD720 = "hd"
    case SD = "sd"
}

enum VideoDownloadMode {
    case file
    case stream
}

struct DownloadSlice {
    let source: URL
    let destination: URL
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

func show(progress: Double, barWidth: Int, speed: String, speedUnits: String) {
    print("\r[", terminator: "")
    let pos = Int(Double(barWidth) * progress / 100.0)
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

    print("] \(String(format: "%.2f", progress))% \(speed)\(speedUnits)", terminator:"     \u{8}\u{8}\u{8}\u{8}\u{8}")
    fflush(__stdoutp)
}

class DownloadSessionManager : NSObject, URLSessionDownloadDelegate {

    static let shared = DownloadSessionManager()
    var fileUrl : URL?
    var url: URL?
    var resumeData: Data?

    var taskStartedAt : Date?
    var downloadedCount = 0
    var totalFileCount = 0
    var cumulativeBytesWritten = Int64(0)

    let semaphore = DispatchSemaphore.init(value: 0)
    var session : URLSession!

    var mode: VideoDownloadMode!

    func resetSession() {
        self.session = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: nil)
    }

    func downloadFile(fromURL url: URL, toFileURL path: URL) {
        self.mode = .file
        resetSession()
        self.fileUrl = path
        self.url = url
        self.resumeData = nil
        taskStartedAt = Date()
        let task = session.downloadTask(with: url)
        task.resume()
        semaphore.wait()
        print("")
    }

    func downloadStream(slices: [DownloadSlice]) {
        self.mode = .stream
        downloadedCount = 0
        totalFileCount = slices.count
        cumulativeBytesWritten = 0

        taskStartedAt = Date()

        show(progress: 0, barWidth: 70, speed: String(0), speedUnits: "KB/s")
        slices.forEach { slice in
            let destination = slice.destination.appendingPathComponent(slice.source.lastPathComponent).path
            guard !FileManager.default.fileExists(atPath: destination) else {
                downloadedCount += 1

                return
            }

            resetSession()
            self.fileUrl = slice.destination
            self.url = slice.source
            self.resumeData = nil
            let task = session.downloadTask(with: slice.source)
            task.resume()
            semaphore.wait()
        }

        let now = Date()
        let timeDownloaded = now.timeIntervalSince(taskStartedAt!)
        let kbs = String(Int(floor( Float(cumulativeBytesWritten) / 1024.0 / Float(timeDownloaded) ) ))
        show(progress: Double(downloadedCount)/Double(totalFileCount)*100.0, barWidth: 70, speed: kbs, speedUnits: "KB/s")
        print("")
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
            self.downloadFile(fromURL: self.url!, toFileURL: self.fileUrl!)
        }
    }

    //MARK : URLSessionDownloadDelegate stuff
    func urlSession(_: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didWriteData bytesWritten: Int64,
                    totalBytesWritten: Int64,
                    totalBytesExpectedToWrite: Int64) {

        let now = Date()
        let timeDownloaded = now.timeIntervalSince(taskStartedAt!)
        if mode == .stream {
            self.cumulativeBytesWritten += bytesWritten
            let kbs = String(Int(floor( Float(cumulativeBytesWritten) / 1024.0 / Float(timeDownloaded) ) ))
            show(progress: Double(downloadedCount)/Double(totalFileCount)*100.0, barWidth: 70, speed: kbs, speedUnits: "KB/s")

        } else if mode == .file {
            let kbs = String(Int( floor( Float(totalBytesWritten) / 1024.0 / Float(timeDownloaded) ) ))
            show(progress: Double(totalBytesWritten)/Double(totalBytesExpectedToWrite)*100.0, barWidth: 70, speed: kbs, speedUnits: "KB/s")
        }
    }

    func urlSession(_: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        defer {
            semaphore.signal()
        }

        guard let destination = fileUrl?.appendingPathComponent(url!.lastPathComponent) else {
            return
        }

        do {
            try FileManager.default.moveItem(at: location, to: destination)

        } catch let error {
            print("\nOoops! Something went wrong: \(error)")
        }

        downloadedCount += 1
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

        print("\nOoops! Something went wrong: \(error.localizedDescription)")

        guard let resumeData = (error as NSError).userInfo[NSURLSessionDownloadTaskResumeData] as? Data else {
            return
        }

        self.resumeData = resumeData
    }
}

class wwdcVideosController {

    class func getM3URLs(fromHTML: String, session: String) -> URL? {
        let pat = "\\b.*(https://.*\\.m3u8)\\b"
        let regex = try! NSRegularExpression(pattern: pat, options: [])
        let matches = regex.matches(in: fromHTML, options: [], range: NSRange(location: 0, length: fromHTML.count))
        var videoUrl: URL? = nil
        if !matches.isEmpty {
            let range = matches[0].range(at: 1)
            let videoUrlString = String(fromHTML[fromHTML.index(fromHTML.startIndex, offsetBy: range.location) ..< fromHTML.index(fromHTML.startIndex, offsetBy: range.location+range.length)])
            videoUrl = URL(string: videoUrlString)
        }

        return videoUrl
    }

    class func getPlaylistPath(fromPlaylist playlist: String, format: String) -> String? {
        let patterns = [
            "\\s*#EXT-X-STREAM-INF:.*RESOLUTION=\\d*x" + format + ",.*\\s*(.*)\\s*",

            // Fallback to find highest resolution video
            "\\s*#EXT-X-STREAM-INF:.*RESOLUTION=1920x\\d*,.*\\s*(.*)\\s*"
        ]

        var path: String?
        for pattern in patterns {
            if let p = matchPlaylistPath(playlist: playlist, format: format, pattern: pattern) {
                path = p
                break
            }
        }
        return path
    }

    class func matchPlaylistPath(playlist: String, format: String, pattern: String) -> String? {
        let regex = try! NSRegularExpression(pattern: pattern, options: [])
        let matches = regex.matches(in: playlist, options: [], range: NSRange(location: 0, length: playlist.count))

        var path: String?
        if !matches.isEmpty {
            let range = matches[0].range(at:1)
            path = String(playlist[playlist.index(playlist.startIndex, offsetBy: range.location) ..< playlist.index(playlist.startIndex, offsetBy: range.location + range.length)])
        }

        return path
    }

    class func getAudioPlaylistPath(fromPlaylist playlist: String) -> String? {
        let pat = "\\s*#EXT-X-MEDIA:TYPE=AUDIO,.*,URI=\"(.*)\""
        let regex = try! NSRegularExpression(pattern: pat, options: [])
        let matches = regex.matches(in: playlist, options: [], range: NSRange(location: 0, length: playlist.count))

        if !matches.isEmpty {
            let range = matches[0].range(at:1)
            let path = String(playlist[playlist.index(playlist.startIndex, offsetBy: range.location) ..< playlist.index(playlist.startIndex, offsetBy: range.location + range.length)])

            return path
        }

        return nil
    }

    class func getSliceURLs(fromPlaylist playlist: String, baseURL: URL) -> [URL] {
        let pat = "#.*,\\s*(.*)\\s*"
        let regex = try! NSRegularExpression(pattern: pat, options: [])
        let matches = regex.matches(in: playlist, options: [], range: NSRange(location: 0, length: playlist.count))

        return matches.map { $0.range(at: 1) }
            .map { String(playlist[playlist.index(playlist.startIndex, offsetBy: $0.location) ..< playlist.index(playlist.startIndex, offsetBy: $0.location + $0.length)]) }
            .sorted()
            .map { baseURL.appendingPathComponent($0) }
    }

    class func getHDorSDdURLs(fromHTML: String, format: VideoQuality) -> URL? {
        let pat = "\\b.*(https://.*" + format.rawValue + ".*\\.mp4)\\b"
        let regex = try! NSRegularExpression(pattern: pat, options: [])
        let matches = regex.matches(in: fromHTML, options: [], range: NSRange(location: 0, length: fromHTML.count))
        var videoUrl: URL? = nil
        if !matches.isEmpty {
            let range = matches[0].range(at: 1)
            let videoUrlString = String(fromHTML[fromHTML.index(fromHTML.startIndex, offsetBy: range.location) ..< fromHTML.index(fromHTML.startIndex, offsetBy: range.location+range.length)])
            videoUrl = URL(string: videoUrlString)
        }

        return videoUrl
    }

    class func getPDFResourceURL(fromHTML: String, session: String) -> URL? {
        let pat = "\\b.*(https://.*/\(session)_[^/]*\\.pdf)\\b"
        let regex = try! NSRegularExpression(pattern: pat, options: [])
        let matches = regex.matches(in: fromHTML, options: [], range: NSRange(location: 0, length: fromHTML.count))
        var pdfResourceUrl: URL? = nil
        if !matches.isEmpty {
            let range = matches[0].range(at:1)
            let pdfResourceUrlString = String(fromHTML[fromHTML.index(fromHTML.startIndex, offsetBy: range.location) ..< fromHTML.index(fromHTML.startIndex, offsetBy: range.location+range.length)])
            pdfResourceUrl = URL(string: pdfResourceUrlString)
        }
        return pdfResourceUrl
    }

    class func getTitle(fromHTML: String) -> (String) {
        let pat = "<h1>(.*)</h1>"
        let regex = try! NSRegularExpression(pattern: pat, options: [])
        let matches = regex.matches(in: fromHTML, options: [], range: NSRange(location: 0, length: fromHTML.count))
        var title = ""
        if !matches.isEmpty {
            let range = matches[0].range(at:1)
            title = String(fromHTML[fromHTML.index(fromHTML.startIndex, offsetBy: range.location) ..< fromHTML.index(fromHTML.startIndex, offsetBy: range.location+range.length)])
        }

        return title
    }

    class func getSampleCodeURL(fromHTML: String) -> [URL] {
        let pat = "\\b.*(class=\"download\"\\>\\<a href=\".*\")\\b"
        let regex = try! NSRegularExpression(pattern: pat, options: [])
        let matches = regex.matches(in: fromHTML, options: [], range: NSRange(location: 0, length: fromHTML.count))
        var sampleURLPaths : [String] = []
        for match in matches {
            let range = match.range(at:1)
            var path = String(fromHTML[fromHTML.index(fromHTML.startIndex, offsetBy: range.location) ..< fromHTML.index(fromHTML.startIndex, offsetBy: range.location+range.length)])
            path = path.replacingOccurrences(of: "class=\"download\"><a href=\"", with: "")
            if (!path.contains("https://developer.apple.com")) {
                path = "https://developer.apple.com" + path
            }
            path = path.replacingOccurrences(of: "\" target=\"", with: "/")

            sampleURLPaths.append(path)
        }

        var sampleArchiveUrls : [URL] = []
        for urlPath in sampleURLPaths {
            if let url = getDownloadPageURL(urlPath: urlPath) {
                sampleArchiveUrls.append(url)
            }
        }

        return sampleArchiveUrls
    }

    class func getDownloadPageURL(urlPath: String) -> URL? {
        let archivePat = "href=\"https.*?\\.zip"
        let archiveRegex = try! NSRegularExpression(pattern: archivePat, options: [])
        let downloadPage = getStringContent(fromURL: urlPath)
        let matches = archiveRegex.matches(in: downloadPage, options: [], range: NSRange(location: 0, length: downloadPage.count))
        for match in matches {
            let range = match.range(at:0)
            var path = String(downloadPage[downloadPage.index(downloadPage.startIndex, offsetBy: range.location) ..< downloadPage.index(downloadPage.startIndex, offsetBy: range.location+range.length)])
            path = path.replacingOccurrences(of: "href=\"", with: "")
            return URL(string: path)
        }

        return nil
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
         My API (2) (GET https://developer.apple.com/videos/play/wwdc2019/201/)
         https://developer.apple.com/videos/play/wwdc2019/102/
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

    class func getSessionsList(fromHTML: String, type: String) -> Array<String> {
        let pat = "\"\\/videos\\/play\\/\(type)\\/([0-9]*)\\/\""
        let regex = try! NSRegularExpression(pattern: pat, options: [])
        let matches = regex.matches(in: fromHTML, options: [], range: NSRange(location: 0, length: fromHTML.count))
        var sessionsListArray = [String]()
        for match in matches {
            for n in 0..<match.numberOfRanges {
                let range = match.range(at:n)
                switch n {
                case 1:
                    sessionsListArray.append(String(fromHTML[fromHTML.index(fromHTML.startIndex, offsetBy: range.location) ..< fromHTML.index(fromHTML.startIndex, offsetBy: range.location+range.length)]))
                default: break
                }
            }
        }
        return sessionsListArray
    }

    class func downloadFile(fromUrl url: URL, forSession session: String = "???") {
        guard !FileManager.default.fileExists(atPath: "./" + url.lastPathComponent) else {
            print("\(url.lastPathComponent): already exists, nothing to do!")
            return
        }

        let fileUrl = URL(fileURLWithPath: url.lastPathComponent)
        print("[Session \(session)] Getting \(fileUrl.lastPathComponent) (\(url.absoluteString)):")

        DownloadSessionManager.shared.downloadFile(fromURL: url, toFileURL: fileUrl.deletingLastPathComponent())
    }

    class func downloadStream(playlistUrl: URL, toFile filename: String, forFormat format: String = "1080", forSession session: String = "???") {

        let fileManager = FileManager.default

        let fileUrl = URL(fileURLWithPath: filename)
        guard !fileManager.fileExists(atPath: "./" + filename) else {
            print("\(filename): already exists, nothing to do!")
            return
        }

        print("[Session \(session)] Getting \(filename):")

        guard let playlist = try? String(contentsOf: playlistUrl) else {
            print("\(filename): could not download playlist!")
            return
        }

        guard let playlistPath = getPlaylistPath(fromPlaylist: playlist, format: format) else {
            print("Something went wrong getting download path")
            return
        }

        let slicesURL: URL?
        let sliceRelativePath: String
        if playlistPath.hasPrefix("https://") {
            slicesURL = URL(string: playlistPath)
            sliceRelativePath = String(playlistPath.dropFirst(8))

        } else if playlistPath.hasPrefix("http://") {
            slicesURL = URL(string: playlistPath)
            sliceRelativePath = String(playlistPath.dropFirst(7))
        
        } else {
            slicesURL = playlistUrl.deletingLastPathComponent().appendingPathComponent(playlistPath)
            sliceRelativePath = playlistPath
        }

        guard let slicePlaylistURL = slicesURL, let slicePlaylist = try? String(contentsOf: slicePlaylistURL) else {
            print("\(filename): Could not retrieve stream playlist!")
            return
        }

        let baseURL = slicePlaylistURL.deletingLastPathComponent()
        let sliceURLs = getSliceURLs(fromPlaylist: slicePlaylist, baseURL: baseURL)

        let tempUrl = fileUrl.appendingPathExtension("part")

        guard let newPlaylist = cleanupPlaylist(playlist: playlist, format: format),
              let videoUrl = getVideoUrl(playlist: newPlaylist, baseUrl:  tempUrl) else {
            print("Something went wrong getting video path")

            return
        }

        try? fileManager.createDirectory(at: videoUrl, withIntermediateDirectories: true, attributes: nil)
        // TODO: Check if directory already exist and handle error

        let playlistFileUrl = tempUrl.appendingPathComponent("playlist").appendingPathExtension("m3u8")
        let slicePlaylistFileUrl = tempUrl.appendingPathComponent(sliceRelativePath)
        try? fileManager.removeItem(at: playlistFileUrl)
        try? fileManager.removeItem(at: slicePlaylistFileUrl)
        do {
            try newPlaylist.write(to: playlistFileUrl, atomically: false, encoding: .utf8)
            try slicePlaylist.write(to: slicePlaylistFileUrl, atomically: false, encoding: .utf8)

        } catch {
            print("Could not write playlist file!")
            try? fileManager.removeItem(at: tempUrl)

            return
        }

        var downloadSlices = sliceURLs.map { DownloadSlice(source: $0, destination: videoUrl) }

        if let audioPlaylistPath = getAudioPlaylistPath(fromPlaylist: newPlaylist),
           let audioUrl = getAudioUrl(playlist: newPlaylist, baseUrl: tempUrl) {

            let audioSlicesUrl = playlistUrl.deletingLastPathComponent().appendingPathComponent(audioPlaylistPath)
            let audioBaseUrl = audioSlicesUrl.deletingLastPathComponent()
            guard let audioSlicePlaylist = try? String(contentsOf: audioSlicesUrl) else {
                print("\(filename): Could not retrieve audio stream playlist!")
                return
            }

            let audioSliceURLs = getSliceURLs(fromPlaylist: audioSlicePlaylist, baseURL: audioBaseUrl)

            let sliceAudioPlaylistFileUrl = tempUrl.appendingPathComponent(audioPlaylistPath)

            try? fileManager.createDirectory(at: audioUrl, withIntermediateDirectories: true, attributes: nil)
            try? fileManager.removeItem(at: sliceAudioPlaylistFileUrl)
            do {
                try audioSlicePlaylist.write(to: sliceAudioPlaylistFileUrl, atomically: false, encoding: .utf8)

            } catch {
                print("Could not write playlist file!")

                return
            }

            downloadSlices += audioSliceURLs.map { DownloadSlice(source: $0, destination: audioUrl) }
        }

        DownloadSessionManager.shared.downloadStream(slices: downloadSlices)

        if let command = commandPath(command: "ffmpeg") {
            print("[Session \(session)] Converting (ffmpeg) \(filename):")

            let ffmpegFilelist = sliceURLs.map { videoUrl.appendingPathComponent($0.lastPathComponent).path }
            ffmpeg(command: command, filelist: ffmpegFilelist, tsBaseUrl: playlistUrl, playlistFileUrl: playlistFileUrl, tempDirBaseUrl: tempUrl, outFile: filename)

        } else {
            print("No converter!")
        }
    }

    class func getVideoUrl(playlist: String, baseUrl: URL) -> URL? {
        let regex = try! NSRegularExpression(pattern: "^#EXT-X-STREAM-INF:.*\n*(.*)/", options: [.anchorsMatchLines])
        let matches = regex.matches(in: playlist, options: [], range: NSRange(location: 0, length: playlist.count))

        if !matches.isEmpty {
            let range = matches[0].range(at: 1)
            let path = String(playlist[playlist.index(playlist.startIndex, offsetBy: range.location) ..<
                                         playlist.index(playlist.startIndex, offsetBy: range.location+range.length)])

            let videoPath = dropProtocol(fromUrlString: path)
            
            return baseUrl.appendingPathComponent(videoPath)
        }

        return nil
    }

    class func getAudioUrl(playlist: String, baseUrl: URL) -> URL? {
        let audioPathRegex = try! NSRegularExpression(pattern: "^#EXT-X-MEDIA:TYPE=AUDIO,.*,URI=\"(.*)/.*\"", options: [.anchorsMatchLines])
        let audioPathMatches = audioPathRegex.matches(in: playlist, options: [], range: NSRange(location: 0, length: playlist.count))
        var audioPath = ""
        if !audioPathMatches.isEmpty {
            let range = audioPathMatches[0].range(at: 1)
            audioPath = String(playlist[playlist.index(playlist.startIndex, offsetBy: range.location) ..<
                                        playlist.index(playlist.startIndex, offsetBy: range.location+range.length)])

            return baseUrl.appendingPathComponent(audioPath)
        }

        return nil
    }
    
    class func cleanupPlaylist(playlist: String, format: String) -> String? {
        let patterns = [
            "\n#EXT-X-STREAM-INF:.*RESOLUTION=\\d*x" + format + ",.*\n*.*\n#EXT-X-I-FRAME-STREAM-INF:[^\n]*",
            "\n#EXT-X-STREAM-INF:.*RESOLUTION=\\d*x" + format + ",[^\n]*\n[^\n]*\n",

            // Fallback to find highest resolution video
            "\n#EXT-X-STREAM-INF:.*RESOLUTION=1920x\\d*,.*\n.*\n#EXT-X-I-FRAME-STREAM-INF:[^\n]*",
            "\n#EXT-X-STREAM-INF:.*RESOLUTION=1920x\\d*,[^\n]*\n[^\n]*\n"
        ]

        var newPlaylist: String?

        for pattern in patterns {
            if let pl = keepOnly(playlist: playlist, withPattern: pattern) {
                newPlaylist = pl
                break
            }
        }

        return newPlaylist
    }

    class func keepOnly(playlist: String, withPattern pattern: String) -> String? {
        let regex = try! NSRegularExpression(pattern: pattern, options: [])
        let matches = regex.matches(in: playlist, options: [.withTransparentBounds], range: NSRange(location: 0, length: playlist.count))

        var videoStreamLine: String?
        if !matches.isEmpty {
            let range = matches[0].range

            let streamLine = String(playlist[playlist.index(playlist.startIndex, offsetBy: range.location) ..<
                                               playlist.index(playlist.startIndex, offsetBy: range.location + range.length)])

            videoStreamLine = dropProtocol(fromUrlString: streamLine)
        }

        if let videoStreamLine = videoStreamLine {
            let pattern = "#EXT-X-STREAM-INF:.*[^\n]*"
            let regex = try! NSRegularExpression(pattern: pattern, options: .dotMatchesLineSeparators)
            let newPlaylist = regex.stringByReplacingMatches(in: playlist, options: [], range: NSRange(location: 0, length: playlist.count), withTemplate: videoStreamLine)

            return newPlaylist
        }

        return nil
    }

}

func ffmpeg(command: String, filelist: [String], tsBaseUrl: URL, playlistFileUrl: URL, tempDirBaseUrl: URL, outFile filename: String) {
    let fileManager = FileManager.default
    let tsSize = filelist.reduce(Int64(0)) { initial, file in
        let sum = try! fileManager.attributesOfItem(atPath: file)[FileAttributeKey.size] as! Int64
        return initial + sum
    }

    let task = Process()
    task.launchPath = command
    task.arguments = ["-progress", "-", "-i", playlistFileUrl.path, "-c", "copy", filename]
    let standardOutput = Pipe()
    task.standardOutput = standardOutput
    task.standardError = FileHandle.nullDevice
    task.standardInput = FileHandle.nullDevice
    task.launch()

    var data = standardOutput.fileHandleForReading.availableData

    show(progress: 0, barWidth: 70, speed: String(0), speedUnits: "kbits/s")
    while data.count != 0 {
        let output = String(data: data, encoding: .utf8)!

        let bitratePattern = "bitrate=([\\d.]*)kbits"
        let bitrateRegex = try! NSRegularExpression(pattern: bitratePattern, options: [])
        let matchesBitrate = bitrateRegex.matches(in: output, options: [], range: NSRange(location: 0, length: output.count))

        let sizePattern = "total_size=(\\d*)\\s"
        let sizeRegex = try! NSRegularExpression(pattern: sizePattern, options: [])
        let matchesSize = sizeRegex.matches(in: output, options: [], range: NSRange(location: 0, length: output.count))

        let progressPattern = "\\sprogress=(.*)\\s"
        let progressRegex = try! NSRegularExpression(pattern: progressPattern, options: [])
        let matchesProgress = progressRegex.matches(in: output, options: [], range: NSRange(location: 0, length: output.count))

        var speed = "0"
        var progress = 0.0
        var size = 0.0

        if !matchesBitrate.isEmpty {
            let bitrateRange = matchesBitrate[0].range(at: 1)
            let bitrate = Double(String(output[output.index(output.startIndex, offsetBy: bitrateRange.location) ..< output.index(output.startIndex, offsetBy: bitrateRange.location + bitrateRange.length)]))!

            speed = String(Int((bitrate * 0.125).rounded()))
        }

        if !matchesSize.isEmpty {
            let sizeRange = matchesSize[0].range(at: 1)
            size = Double(String(output[output.index(output.startIndex, offsetBy: sizeRange.location) ..< output.index(output.startIndex, offsetBy: sizeRange.location + sizeRange.length)]))!
        }

        if !matchesProgress.isEmpty {
            let progressRange = matchesProgress[0].range(at: 1)
            let progressString = String(output[output.index(output.startIndex, offsetBy: progressRange.location) ..< output.index(output.startIndex, offsetBy: progressRange.location + progressRange.length)])

            if progressString == "continue" {
                progress = size / Double(tsSize) * 100
            } else {
                progress = 100.0
            }
        }

        show(progress: progress, barWidth: 70, speed: speed, speedUnits: "kbits/s")

        data = standardOutput.fileHandleForReading.availableData
    }

    if !task.isRunning && task.terminationStatus == 0 {
        try? FileManager.default.removeItem(at: tempDirBaseUrl)
    }

    print("")
}

func commandPath(command: String) -> String? {
    let task = Process()
    task.launchPath = "/bin/bash"
    task.arguments = ["command", "-v", command]
    let standardOutput = Pipe()
    task.standardOutput = standardOutput
    task.launch()

    var data = standardOutput.fileHandleForReading.readDataToEndOfFile()

    if data.count == 0 {
        return nil

    } else {
        data.removeLast()
    }

    return String(data: data, encoding: .utf8)
}

func dropProtocol(fromUrlString urlString: String) -> String {
    let pattern = "https*://"
    let regex = try! NSRegularExpression(pattern: pattern, options: .dotMatchesLineSeparators)
    let path = regex.stringByReplacingMatches(in: urlString, options: [], range: NSRange(location: 0, length: urlString.count), withTemplate: "")

    return path
}

func showHelpAndExit() {
    print("wwdcDownloader - a simple swifty video sessions bulk download.\nJust Get'em all!")
    print("usage: wwdcDownloader.swift [--wwdc-year <year>] [--tech-talks] [--hd1080] [--hd720] [--sd] [--pdf] [--pdf-only] [--sessions <number>] [--sample] [--list-only] [--help]\n")
    exit(0)
}

/* Managing options */
let wwdcIndexUrlBaseString = "https://developer.apple.com/videos/"
let wwdcSessionUrlBaseString = "https://developer.apple.com/videos/play/"
var videoType = "wwdc2019"
var format = VideoQuality.HD1080
var videoDownloadMode = VideoDownloadMode.stream

var shouldDownloadPDFResource = false
var shouldDownloadVideoResource = true
var shouldDownloadSampleCodeResource = false

var shouldDownloadTechTalksVideoResource = false
var shouldDownloadWWDCVideoResource = false

var gettingSessions = false
var sessionsSet:Set<String> = Set()

var arguments = CommandLine.arguments
arguments.remove(at: 0)

var iterator = arguments.makeIterator()

while let argument = iterator.next() {
    switch argument {

    case "-h", "--help":
        showHelpAndExit()
        break

    case "--hd1080":
        format = .HD1080
        break

    case "--hd720":
        format = .HD720
        videoDownloadMode = .file
        break

    case "--sd":
        format = .SD
        videoDownloadMode = .file
        break

    case "--pdf":
        shouldDownloadPDFResource = true
        break

    case "--pdf-only":
        shouldDownloadPDFResource = true
        shouldDownloadVideoResource = false
        break

    case "--sample":
        shouldDownloadSampleCodeResource = true
        break

    case "--sample-only":
        shouldDownloadSampleCodeResource = true
        shouldDownloadVideoResource = false
        break

    case "--sessions", "-s":
        gettingSessions = true

        if let session = iterator.next() {
            if Int(session) != nil {
                sessionsSet.insert(session)

            } else {
                print("\(session) is not a valid session nuber")
                showHelpAndExit()
            }

        } else {
            print("Missing session number")
            showHelpAndExit()
        }

        break

    case "--list-only", "-l":
        shouldDownloadVideoResource = false
        break

    case "--tech-talks":
        if shouldDownloadWWDCVideoResource == true {
            print("Could not download WWDC and Tech Talks videos at the same time")
            showHelpAndExit()
        }
        
        videoType = "tech-talks"
        shouldDownloadTechTalksVideoResource = true
        break

    case "--wwdc-year":
        if shouldDownloadTechTalksVideoResource == true {
            print("Could not download WWDC and Tech Talks videos at the same time")
            showHelpAndExit()
        }

        if let yearString = iterator.next() {
            if let year = Int(yearString) {
                let today = Date()
                let currentYear = Calendar.current.component(.year, from: today)
                let currentMonth = Calendar.current.component(.month, from: today)

                if year > currentYear || (year == currentYear && currentMonth < 6) {
                    print("WWDC \(yearString) videos are not yet available")
                    showHelpAndExit()

                } else if year < 2012 {
                    print("WWDC videos earlier than 2012 were not made available for downloads")
                    showHelpAndExit()

                    
                } else {
                    videoType = "wwdc\(yearString)"
                    shouldDownloadWWDCVideoResource = true
                }

            } else {
                print("\(yearString) is not a valid year")
                showHelpAndExit()
            }

        } else {
            print("Missing year")
            showHelpAndExit()
        }

        break

    default:
	if gettingSessions {
            if Int(argument) != nil {
                sessionsSet.insert(argument)
                break
            } else {
                gettingSessions = false
            }
        }
        print("\(argument) is not a \(#file) command.\n")
        showHelpAndExit()
    }
}

var wwdcIndexUrlString = wwdcIndexUrlBaseString + videoType + "/"
var wwdcSessionUrlString = wwdcSessionUrlBaseString + videoType + "/"

if(shouldDownloadVideoResource) {
    switch format {
    case .HD1080:
        if commandPath(command: "ffmpeg") == nil {
            print("Could not find ffmpeg. wwdcDownloader will download video stream but will not be able to convert to mp4 video files.")
            print("Convertion can be done after the stream files are downloaded and ffmpeg installed.")

        } else {
            print("Downloading 1080p videos in current directory")
        }

    case .HD720:
        print("Downloading 720p videos in current directory")

    case .SD:
        print("Downloading SD videos in current directory")
    }
}

func makeFilename(fromTitle title: String, session: String, format: String, ext: String) -> String {
    let normalizedTitle = String(title.unicodeScalars.filter { $0.isASCII }
        .map { Character($0) }
        .filter { !"-':,.&".contains($0) }
        .map { $0 == " " ? "_" : $0 }).lowercased()

    return session + "_" + format + "p_" + normalizedTitle + "." + ext
}

/* Retreiving list of all video session */
let htmlSessionListString = wwdcVideosController.getStringContent(fromURL: wwdcIndexUrlString)
print("Let me ask Apple about currently available sessions. This can take some times (15 to 20 sec.) ...")
var sessionsListArray = wwdcVideosController.getSessionsList(fromHTML: htmlSessionListString, type: videoType)
//get unique values
sessionsListArray=Array(Set(sessionsListArray))

/* getting individual videos */
if sessionsSet.count != 0 {
    let sessionsListSet = Set(sessionsListArray)
    sessionsListArray = Array(sessionsSet.intersection(sessionsListSet))
}

sessionsListArray.sorted(by: { $0.compare($1, options: .numeric) == .orderedAscending }).forEach { session in
    let htmlText = wwdcVideosController.getStringContent(fromURL: wwdcSessionUrlString + session + "/")
    let title = wwdcVideosController.getTitle(fromHTML: htmlText)
    print("\n[Session \(session)] : \(title)")

    if shouldDownloadVideoResource {
        let url: URL?
        if videoDownloadMode == .stream {
            url = wwdcVideosController.getM3URLs(fromHTML: htmlText, session: session)
        } else {
            url = wwdcVideosController.getHDorSDdURLs(fromHTML: htmlText, format: format)
        }

        guard let videoUrl = url else {
            print("Video : Video is not yet available !!!")
            return
        }

        if videoDownloadMode == .stream {
            let filename = makeFilename(fromTitle: title, session: session, format: format.rawValue, ext: "mp4")
            print("Video : \(filename)")
            wwdcVideosController.downloadStream(playlistUrl: videoUrl, toFile: filename, forFormat: format.rawValue, forSession: session)

        } else {
            print("Video : \(videoUrl.lastPathComponent)")
            wwdcVideosController.downloadFile(fromUrl: videoUrl, forSession: session)
        }
    }

    if shouldDownloadPDFResource {
        let url = wwdcVideosController.getPDFResourceURL(fromHTML: htmlText, session: session)
        guard let pdfResourceUrl = url else {
            print("PDF : PDF is not yet available !!!")
            return
        }

        print("PDF : \(pdfResourceUrl.lastPathComponent)")
        wwdcVideosController.downloadFile(fromUrl: pdfResourceUrl, forSession: session)
    }

    if shouldDownloadSampleCodeResource {
        let sampleUrls = wwdcVideosController.getSampleCodeURL(fromHTML: htmlText)
        if sampleUrls.isEmpty {
            print("SampleCode: Resource not yet available !!!")
        } else {
            print("SampleCode: ")
            for url in sampleUrls {
                print("\(url.lastPathComponent)")
                wwdcVideosController.downloadFile(fromUrl: url, forSession: session)
            }
        }
    }
}
