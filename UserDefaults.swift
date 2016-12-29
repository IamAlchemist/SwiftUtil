//
//  UserDefaults.swift
//
//  Created by wizard lee on 8/24/16.
//  Copyright © 2016 wizard lee. All rights reserved.
//

import Foundation

struct MWUserDefaultsValue {
    private let key : String
    private var defaults: UserDefaults {
        get {
            return UserDefaults.standard
        }
    }
    
    init(key: String) {
        self.key = key
    }
    
    func clear() {
        defaults.removeObject(forKey: key)
    }
    
    func save(value: NSData) {
        defaults.set(value, forKey: key)
    }
    
    func save(value: String) {
        defaults.set(value, forKey: key)
    }
    
    func save(value: Int) {
        defaults.set(value, forKey: key)
    }
    
    func save(value: Float) {
        defaults.set(value, forKey: key)
    }
    
    func save(value: Double) {
        defaults.set(value, forKey: key)
    }
    
    func save(value: Bool) {
        defaults.set(value, forKey: key)
    }
    
    func save(value: NSDate) {
        defaults.set(value, forKey: key)
    }
    
    func save<T: AnyObject>(value: [T]) {
        defaults.set((value as NSArray), forKey: key)
    }
    
    func save(value: [NSObject: AnyObject]) {
        defaults.set(value, forKey: key)
    }
    
    var data : NSData? {
        get {
            return defaults.object(forKey: key) as? NSData
        }
    }
    
    var string : String? {
        get {
            return defaults.string(forKey: key)
        }
    }
    
    var int : Int? {
        get {
            return number?.intValue
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
            return defaults.object(forKey: key) as? NSDate
        }
    }
    
    var array : [AnyObject]? {
        get {
            return defaults.object(forKey: key) as? [AnyObject]
        }
    }
    
    var dictionary : [NSObject: AnyObject]? {
        get {
            return defaults.object(forKey: key) as? [NSObject: AnyObject]
        }
    }
    
    private var number : NSNumber? {
        get {
            return defaults.object(forKey: key) as? NSNumber
        }
    }
}
