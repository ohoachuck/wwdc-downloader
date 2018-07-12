#!/usr/bin/swift

/*
	Author: Olivier HO-A-CHUCK
	Date: June 17th 2017
	About this script:
 WWDC 2018 is ending and even if there are some great tools out there (https://github.com/insidegui/WWDC) that allow to see and download video sessions,
 I Still need to get my video doggy bag to fly back home. And Moscone alsways provide with great bandwidth.
 So as I had never really started to code in Swift I decided to start here (I know it's late - but I'm no more a developer) and copy/pasted some internet peace
 of codes to get a Swift Script that bulk download all sessions.
 You may have understand my usual disclamer : "I'm a Marketing guy" so don't blame my messy (Swift beginer) code.
 Please feel free to make this script better if you feel like so. There is plenty to do.
	
	License: Do what you want with it. But notice that this script comes with no warranty and will not be maintained.
	Usage: wwdc2018.swift
	Default behavior: without any options the script will download all available hd videos. And will re-take non fully downloaded ones.
	Please use --help option to get currently available options
 
	TODO:
 - basically all previous script option (previuous years, checks, cleaner code, etc.)
 
 
 Note: SF Tested with Apple Swift version 4.1.2 (swiftlang-902.0.54 clang-902.0.39.2)
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

    func downloadStream(fromUrls urls: [URL], toPath path: URL) {
        self.mode = .stream
        downloadedCount = 0
        totalFileCount = urls.count
        cumulativeBytesWritten = 0

        taskStartedAt = Date()

        show(progress: 0, barWidth: 70, speed: String(0), speedUnits: "KB/s")
        urls.forEach { url in
            let destination = path.appendingPathComponent(url.lastPathComponent).path
            guard !FileManager.default.fileExists(atPath: destination) else {
                downloadedCount += 1

                return
            }

            resetSession()
            self.fileUrl = path
            self.url = url
            self.resumeData = nil
            let task = session.downloadTask(with: url)
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

    class func getPlaylistURLs(fromPlaylist playlist: String, format: String) -> String {
        let pat = "\\s*#EXT-X-STREAM-INF:.*RESOLUTION=\\d*x" + format + ",.*\\s*(.*)\\s*"
        let regex = try! NSRegularExpression(pattern: pat, options: [])
        let matches = regex.matches(in: playlist, options: [], range: NSRange(location: 0, length: playlist.count))

        var path = ""
        if !matches.isEmpty {
            let range = matches[0].range(at:1)
            path = String(playlist[playlist.index(playlist.startIndex, offsetBy: range.location) ..< playlist.index(playlist.startIndex, offsetBy: range.location + range.length)])
        }

        return path
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
        let pat = "\\b.*(href=\".*/content/samplecode/.*\")\\b"
        let regex = try! NSRegularExpression(pattern: pat, options: [])
        let matches = regex.matches(in: fromHTML, options: [], range: NSRange(location: 0, length: fromHTML.count))
        var sampleURLPaths : [String] = []
        for match in matches {
            let range = match.range(at:1)
            var path = String(fromHTML[fromHTML.index(fromHTML.startIndex, offsetBy: range.location) ..< fromHTML.index(fromHTML.startIndex, offsetBy: range.location+range.length)])
            path = path.replacingOccurrences(of: "href=\"", with: "https://developer.apple.com")
            path = path.replacingOccurrences(of: "\" target=\"", with: "/")

            sampleURLPaths.append(path)
        }

        var sampleArchiveUrls : [URL] = []
        for urlPath in sampleURLPaths {
            let jsonText = getStringContent(fromURL: urlPath + "book.json")
            if let data = jsonText.data(using: .utf8) {
                let object = try? JSONSerialization.jsonObject(with: data, options: .allowFragments)
                if let dictionary = object as? NSDictionary {
                    if let relativePath = dictionary["sampleCode"] as? String, let url = URL(string: urlPath + relativePath) {
                        sampleArchiveUrls.append(url)
                    }
                }
            }
        }

        return sampleArchiveUrls
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
         My API (2) (GET https://developer.apple.com/videos/play/wwdc2018/201/)
         https://developer.apple.com/videos/play/wwdc2018/102/
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
        let pat = "\"\\/videos\\/play\\/wwdc2018\\/([0-9]*)\\/\""
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

        let fileUrl = URL(fileURLWithPath: filename)
        guard !FileManager.default.fileExists(atPath: "./" + filename) else {
            print("\(filename): already exists, nothing to do!")
            return
        }

        print("[Session \(session)] Getting \(filename):")

        guard let playlist = try? String(contentsOf: playlistUrl) else {
            print("\(filename): could not download playlist!")
            return
        }

        let path = getPlaylistURLs(fromPlaylist: playlist, format: format)

        let slicesURL: URL?
        if path.hasPrefix("https://") {
            slicesURL = URL(string: path)
        } else {
            slicesURL = playlistUrl.deletingLastPathComponent().appendingPathComponent(path)
        }

        guard let slicePlaylistURL = slicesURL, let slicePlaylist = try? String(contentsOf: slicePlaylistURL) else {
            print("\(filename): Could not retrieve stream playlist!")
            return
        }

        let baseURL = slicePlaylistURL.deletingLastPathComponent()
        let sliceURLs = getSliceURLs(fromPlaylist: slicePlaylist, baseURL: baseURL)

        let tempDir = fileUrl.appendingPathExtension("part")
        try? FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true, attributes: nil)

        DownloadSessionManager.shared.downloadStream(fromUrls: sliceURLs, toPath: tempDir)

        if let command = commandPath(command: "ffmpeg") {
            print("[Session \(session)] Converting (ffmpeg) \(filename):")

            let ffmpegFilelist = sliceURLs.map { tempDir.appendingPathComponent($0.lastPathComponent).path }
            ffmpeg(command: command, filelist: ffmpegFilelist, tsBaseUrl: tempDir, outFile: filename)

        } else if let command = commandPath(command: "avconvert") {
            print("[Session \(session)] Converting (avconvert) \(filename):")

            let avconvertPlaylist = sliceURLs.map { tempDir.appendingPathComponent($0.lastPathComponent).path }
            avconvert(command: command, playlist: avconvertPlaylist, tsBaseUrl: tempDir, outFile: filename)

        } else {
            print("No converter!")
        }
    }
}

func mergeFile(files: [String], toFile destinationFile: URL) throws {
    if FileManager.default.fileExists(atPath: destinationFile.path) {
        try? FileManager.default.removeItem(at: destinationFile)
    }

    try files.sorted().forEach { url in
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: url))

            if let fileHandle = try? FileHandle(forWritingTo: destinationFile) {
                defer {
                    fileHandle.closeFile()
                }

                fileHandle.seekToEndOfFile()
                fileHandle.write(data)

            } else {
                try data.write(to: destinationFile)
            }

        } catch let error {
            try? FileManager.default.removeItem(at: destinationFile)

            throw error
        }
    }
}

func avconvert(command: String, playlist: [String], tsBaseUrl: URL, outFile: String) {
    let combineTsUrl = tsBaseUrl.appendingPathComponent("combined").appendingPathExtension("ts")
    defer {
        try? FileManager.default.removeItem(at: combineTsUrl)
    }

    do {
        try mergeFile(files: playlist, toFile: combineTsUrl)

    } catch let error {
        print("\nOoops! Something went wrong: \(error.localizedDescription)")

        return
    }

    let task = Process()
    task.launchPath = command
    task.arguments = ["-prog", "-p", "PresetAppleM4V1080pHD", "-s", combineTsUrl.path, "-o", outFile]
    let standardError = Pipe()
    task.standardOutput = FileHandle.nullDevice
    task.standardError = standardError
    task.standardInput = FileHandle.nullDevice
    task.launch()

    var data = standardError.fileHandleForReading.availableData

    show(progress: 0, barWidth: 70, speed: "", speedUnits: "")
    while data.count != 0 {

        let output = String(data: data, encoding: .utf8)!

        let progressPattern = "avconvert progress=([\\d.]*)%.\\s"
        let progressRegex = try! NSRegularExpression(pattern: progressPattern, options: [])
        let matchesProgress = progressRegex.matches(in: output, options: [], range: NSRange(location: 0, length: output.count))

        var progress = 0.0

        if !matchesProgress.isEmpty {
            let progressRange = matchesProgress[0].range(at: 1)
            progress = Double(String(output[output.index(output.startIndex, offsetBy: progressRange.location) ..< output.index(output.startIndex, offsetBy: progressRange.location + progressRange.length)]))!

            show(progress: progress, barWidth: 70, speed: "", speedUnits: "")
        }
        data = standardError.fileHandleForReading.availableData
    }
    show(progress: 100.0, barWidth: 70, speed: "", speedUnits: "")

    if !task.isRunning && task.terminationStatus == 0 {
        try? FileManager.default.removeItem(at: tsBaseUrl)
    }

    print("")
}

func ffmpeg(command: String, filelist: [String], tsBaseUrl: URL, outFile filename: String) {
    let fileManager = FileManager.default
    let tsSize = filelist.reduce(Int64(0)) { initial, file in
        let sum = try! fileManager.attributesOfItem(atPath: file)[FileAttributeKey.size] as! Int64
        return initial + sum
    }

    let ffmpegFilelist = filelist.reduce("") { initial, file in "\(initial)file '\(file)'\n" }
    let ffmpegPlaylistURL = tsBaseUrl.appendingPathComponent("ffmpegFilelist.txt")
    do {
        try ffmpegFilelist.write(to: ffmpegPlaylistURL , atomically: true, encoding: .utf8)

    } catch {
        print("Ooops! Something went wrong: \(error)")
    }

    let task = Process()
    task.launchPath = command
    task.arguments = ["-progress", "-", "-f", "concat", "-safe", "0", "-i", ffmpegPlaylistURL.path, "-c", "copy", filename]
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
        try? FileManager.default.removeItem(at: tsBaseUrl)
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

func showHelpAndExit() {
    print("wwdc2018 - a simple swifty video sessions bulk download.\nJust Get'em all!")
    print("usage: wwdc2018.swift [--hd1080] [--hd] [--sd] [--pdf] [--pdf-only] [--sessions] [--sample] [--list-only] [--help]\n")
    exit(0)
}

/* Managing options */
var wwdcIndexUrlString = "https://developer.apple.com/videos/wwdc2018/"
var wwdcSessionUrlString = "https://developer.apple.com/videos/play/wwdc2018/"
var format = VideoQuality.HD720
var videoDownloadMode = VideoDownloadMode.stream

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

    case "--hd1080":
        format = .HD1080
        gettingSessions = false

    case "--hd720":
        format = .HD720
        gettingSessions = false
        videoDownloadMode = .file

    case "--sd":
        format = .SD
        gettingSessions = false
        videoDownloadMode = .file

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
    case .HD1080:
        print("Downloading 1080p videos in current directory")

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
var sessionsListArray = wwdcVideosController.getSessionsList(fromHTML: htmlSessionListString)
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
