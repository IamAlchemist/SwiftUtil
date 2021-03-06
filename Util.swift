//
//  Util.swift
//
//  Created by wizard lee on 8/12/16.
//  Copyright © 2016 wizard lee. All rights reserved.
//

import Foundation
#if !ASSRC
import CleanroomLogger
#endif
import CoreData

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
        let config = XcodeLogConfiguration()
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
    
    static func alert(message: String, viewController: UIViewController) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "知道了", style: .default, handler: nil)
        alertController.addAction(action)
        viewController.present(alertController, animated: true, completion: nil)
        
    }
    
    static func setTitle(color: UIColor, for navigationBar: UINavigationBar?) {
        guard let navigationBar = navigationBar else { return  }
        var dict = navigationBar.titleTextAttributes ?? [String:Any]()
        dict[NSForegroundColorAttributeName] = color
        navigationBar.titleTextAttributes = dict
    }
    
    static func colorFrom(hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.characters.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    static func pinyinFrom(source: String, withSpace: Bool = false) -> String? {
        let str = NSMutableString(string: source) as CFMutableString
        
        if CFStringTransform(str, nil, kCFStringTransformMandarinLatin, false) {
            if CFStringTransform(str, nil, kCFStringTransformStripDiacritics, false) {
                let result = str as String
                if withSpace {
                    return result
                }
                else {
                    return result.replacingOccurrences(of: " ", with: "")
                }
            }
        }
        
        return nil
    }
    
    static func urlFrom(string: String) -> URL? {
        if let url = URL(string: string) {
            return url
        }
        
        let urlString = string.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? string
        return URL(string: urlString)
    }
    
    static func appVersion() -> String {
        return (Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String) ?? "0"
    }
    
    static func appBuild() -> String {
        return (Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String) ?? "0"
    }
}

