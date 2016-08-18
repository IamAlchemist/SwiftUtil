//
//  Util.swift
//  H5Cache
//
//  Created by wizard lee on 8/12/16.
//  Copyright © 2016 wizard lee. All rights reserved.
//

import Foundation
import CleanroomLogger

struct HulkColorTable : ColorTable {
    func foregroundColorForSeverity(severity: LogSeverity) -> Color? {
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
}

public struct MWUtil {
    public static func applicationDocumentsDirectory() -> NSURL? {
        return NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).last
    }
    
    public static func createDirectory(baseURL: NSURL, path: String) -> Bool {
        do {
            try NSFileManager.defaultManager().createDirectoryAtURL(baseURL.URLByAppendingPathComponent(path), withIntermediateDirectories: true, attributes: nil)
            return true
        }
        catch let error as NSError {
            Log.error?.message("can't create downloads folder : \(error.localizedDescription)")
        }
        
        return false
    }
    
    public static func createDirectory(url: NSURL) -> Bool {
        do {
            try NSFileManager.defaultManager().createDirectoryAtURL(url, withIntermediateDirectories: true, attributes: nil)
            return true
        }
        catch let error as NSError {
            Log.error?.message("can't create downloads folder : \(error.localizedDescription)")
        }
        
        return false
    }
    
    public static func directoryExists(path: String) -> Bool {
        return NSFileManager.defaultManager().fileExistsAtPath(path)
    }
    
    public static func setupCleanRoomLogger() {
        setenv("XcodeColors", "YES", 0);
        let formatter = XcodeLogFormatter(timestampStyle: .`default`, severityStyle: .xcode, delimiterStyle: nil, showCallSite: true, showCallingThread: false, colorizer: nil)
        let config = XcodeLogConfiguration(minimumSeverity: .verbose, colorTable: HulkColorTable(), formatter: formatter)
        Log.enable(configuration: config)
    }
}

