//
//  UserDefaults.swift
//  H5Cache
//
//  Created by wizard lee on 8/24/16.
//  Copyright © 2016 wizard lee. All rights reserved.
//

import Foundation

struct MWUserDefaultsValue {
    private let key : String
    private var defaults: NSUserDefaults {
        get {
            return NSUserDefaults.standardUserDefaults()
        }
    }
    
    init(key: String) {
        self.key = key
    }
    
    func clear() {
        defaults.removeObjectForKey(key)
    }
    
    func save(value: NSData) {
        defaults.setObject(value, forKey: key)
    }
    
    func save(value: String) {
        defaults.setObject(value, forKey: key)
    }
    
    func save(value: Int) {
        defaults.setInteger(value, forKey: key)
    }
    
    func save(value: Float) {
        defaults.setFloat(value, forKey: key)
    }
    
    func save(value: Double) {
        defaults.setDouble(value, forKey: key)
    }
    
    func save(value: Bool) {
        defaults.setBool(value, forKey: key)
    }
    
    func save(value: NSDate) {
        defaults.setObject(value, forKey: key)
    }
    
    func save<T: AnyObject>(value: [T]) {
        defaults.setObject((value as NSArray), forKey: key)
    }
    
    func save(value: [NSObject: AnyObject]) {
        defaults.setObject(value, forKey: key)
    }
    
    var data : NSData? {
        get {
            return defaults.objectForKey(key) as? NSData
        }
    }
    
    var string : String? {
        get {
            return defaults.stringForKey(key)
        }
    }
    
    var int : Int? {
        get {
            return number?.integerValue
        }
    }
    
    var float : Float? {
        get {
            return number?.floatValue
        }
    }
    
    var double : Double? {
        get {
            return number?.doubleValue
        }
    }
    
    var bool : Bool? {
        get {
            return number?.boolValue
        }
    }
    
    var date : NSDate? {
        get {
            return defaults.objectForKey(key) as? NSDate
        }
    }
    
    var array : [AnyObject]? {
        get {
            return defaults.objectForKey(key) as? [AnyObject]
        }
    }
    
    var dictionary : [NSObject: AnyObject]? {
        get {
            return defaults.objectForKey(key) as? [NSObject: AnyObject]
        }
    }
    
    private var number : NSNumber? {
        get {
            return defaults.objectForKey(key) as? NSNumber
        }
    }
}