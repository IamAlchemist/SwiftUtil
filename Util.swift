//
//  Util.swift
//  H5Cache
//
//  Created by wizard lee on 8/12/16.
//  Copyright © 2016 wizard lee. All rights reserved.
//

import Foundation
#if !ASSRC
import CleanroomLogger
#endif
import CoreData

struct HulkColorTable : ColorTable {
    func foreground(forSeverity severity: LogSeverity) -> Color? {
        switch severity {
        case .verbose:
            return Color(r: 64, g: 64, b: 64)
        case .debug:
            return Color(r: 128, g: 128, b: 128)
        case .info:
            return Color(r: 0, g: 184, b: 254)
        case .warning:
            return Color(r: 214, g: 134, b: 47)
        case .error:
            return Color(r: 185, g: 81, b: 46)
        }
    }
    
    func background(forSeverity severity: LogSeverity) -> Color? {
        return nil
    }
}

struct MWUtil {
    static func applicationDocumentsDirectory() -> NSURL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last! as NSURL
    }
    
    static func createDirectory(url: NSURL) -> Bool {
        do {
            try FileManager.default.createDirectory(at: url as URL, withIntermediateDirectories: true, attributes: nil)
            return true
        }
        catch let error as NSError {
            Log.error?.message("can't create downloads folder : \(error.localizedDescription)")
        }
        
        return false
    }
    
    static func fileExistsAtPath(path: String) -> Bool {
        return FileManager.default.fileExists(atPath: path)
    }
    
    static func removeDirectory(path: NSURL) {
        let fileManager = FileManager.default
        do {
            let contents = try fileManager.contentsOfDirectory(at: path as URL, includingPropertiesForKeys: nil, options: [])
            for content in contents {
                try fileManager.removeItem(at: content)
            }
            
            try fileManager.removeItem(at: path as URL)
        }
        catch let error as NSError {
            Log.error?.message("could not delete : \(error.localizedDescription)")
        }
    }
    
    static func setupCleanRoomLogger() {
        setenv("XcodeColors", "YES", 0);
        let formatter = XcodeLogFormatter(timestampStyle: .`default`, severityStyle: .xcode, delimiterStyle: nil, showCallSite: true, showCallingThread: false, colorizer: nil)
        let config = XcodeLogConfiguration(minimumSeverity: .verbose, colorTable: HulkColorTable(), formatter: formatter)
        Log.enable(configuration: config)
    }
    
    static func errorWithDomain(domain: String, code: Int, description: NSString) -> NSError {
        let userinfo : [NSObject: AnyObject] = [NSLocalizedDescriptionKey as NSObject: description]
        return NSError(domain: domain, code: code, userInfo: userinfo)
    }
    
    static func stringFromDate(date: Date, format: String = "yyyy-MM-dd") -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.locale = Locale.current
        
        return formatter.string(from: date)
    }
}

