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
    func foregroundColorForSeverity(severity: LogSeverity) -> Color? {
        switch severity {
        case .Verbose:
            return Color(r: 64, g: 64, b: 64)
        case .Debug:
            return Color(r: 128, g: 128, b: 128)
        case .Info:
            return Color(r: 0, g: 184, b: 254)
        case .Warning:
            return Color(r: 214, g: 134, b: 47)
        case .Error:
            return Color(r: 185, g: 81, b: 46)
        }
    }
}

struct MWUtil {
    static func applicationDocumentsDirectory() -> NSURL {
        return NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).last!
    }
    
    static func createDirectory(url: NSURL) -> Bool {
        do {
            try NSFileManager.defaultManager().createDirectoryAtURL(url, withIntermediateDirectories: true, attributes: nil)
            return true
        }
        catch let error as NSError {
            Log.error?.message("can't create downloads folder : \(error.localizedDescription)")
        }
        
        return false
    }
    
    static func fileExistsAtPath(path: String) -> Bool {
        return NSFileManager.defaultManager().fileExistsAtPath(path)
    }
    
    static func removeDirectory(path: NSURL) {
        let fileManager = NSFileManager.defaultManager()
        do {
            let contents = try fileManager.contentsOfDirectoryAtURL(path, includingPropertiesForKeys: nil, options: [])
            for content in contents {
                try fileManager.removeItemAtURL(content)
            }
            
            try fileManager.removeItemAtURL(path)
        }
        catch let error as NSError {
            Log.error?.message("could not delete : \(error.localizedDescription)")
        }
    }
    
    static func setupCleanRoomLogger() {
        setenv("XcodeColors", "YES", 0);
        let formatter = XcodeLogFormatter(timestampStyle: .Default, severityStyle: .Xcode, delimiterStyle: nil, showCallSite: true, showCallingThread: false, colorizer: nil)
        let config = XcodeLogConfiguration(minimumSeverity: .Verbose, colorTable: HulkColorTable(), formatter: formatter)
        Log.enable(configuration: config)
    }
    
    static func errorWithDomain(domain: String, code: Int, description: NSString) -> NSError {
        let userinfo : [NSObject: AnyObject] = [NSLocalizedDescriptionKey: description]
        return NSError(domain: domain, code: code, userInfo: userinfo)
    }
}

