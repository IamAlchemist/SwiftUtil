//
//  DBHelper.swift
//  SwiftUtilExample
//
//  Created by wizard lee on 8/20/16.
//  Copyright © 2016 wizard lee. All rights reserved.
//

import Foundation
import CleanroomLogger
import CoreData

public struct MWDBHelper {
    let managedObjectContext: NSManagedObjectContext
    let mergePolicy: AnyObject
    
    private let MOC_KEY = "H5CACHE_MOC_KEY"
    var currentManagedObjectContext: NSManagedObjectContext {
        get {
            let thisThread = NSThread.currentThread()
            
            if thisThread == NSThread.mainThread() {
                return managedObjectContext
            }
            
            if let threadMOC = thisThread.threadDictionary.objectForKey(MOC_KEY) as? NSManagedObjectContext {
                return threadMOC
            }
            else {
                let threadMOC = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
                thisThread.threadDictionary.setObject(threadMOC, forKey: MOC_KEY)
                threadMOC.parentContext = managedObjectContext
                
                return threadMOC
            }
        }
    }
    
    public init(manageObjectContext: NSManagedObjectContext, mergePolicy: AnyObject = NSMergeByPropertyObjectTrumpMergePolicy){
        self.managedObjectContext = manageObjectContext
        self.mergePolicy = mergePolicy
    }
    
    public func countForEntity(entityName: String, predicate: NSPredicate? = nil, completion: (count: Int, error: NSError?)->Void) {
        let fetchRequest = NSFetchRequest(entityName: entityName)
        fetchRequest.predicate = predicate
        
        let moc = currentManagedObjectContext
        moc.performBlock {
            var error: NSError? = nil
            let result = moc.countForFetchRequest(fetchRequest, error: &error)
            completion(count: result, error: error)
        }
    }
    
    public func countForEntity(entityName: String, predicate: NSPredicate? = nil) -> Int? {
        let fetchRequest = NSFetchRequest(entityName: entityName)
        fetchRequest.predicate = predicate
        
        var error: NSError? = nil
        let result = managedObjectContext.countForFetchRequest(fetchRequest, error: &error)
        if let error = error {
            Log.error?.message("fetch count fail, \(error.localizedDescription)")
            return nil
        }
        
        return result
    }
    
    public func fetchEntity<T: NSManagedObject>(entityName: String,
                            predicate: NSPredicate? = nil,
                            sortDescriptor: NSSortDescriptor? = nil,
                            pageSize: Int = 0,
                            pageIndex: Int = 0,
                            completion: (items: [T]?, error: NSError?)->Void) {
        
        let fetchRequest = NSFetchRequest(entityName: entityName)
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = sortDescriptor == nil ? nil : [sortDescriptor!]
        
        if pageSize > 0 {
            fetchRequest.fetchLimit = pageSize
            fetchRequest.fetchOffset = pageSize * pageIndex
        }
        
        let moc = currentManagedObjectContext
        moc.performBlock {
            do {
                let items = try moc.executeFetchRequest(fetchRequest)
                if let result = items as? [T] {
                    completion(items: result, error: nil)
                }
                else {
                    let error = self.castError(NSStringFromClass(T))
                    completion(items: nil, error: error)
                }
                
            }
            catch let error as NSError {
                print("concurrent fetch fail, \(error.localizedDescription)")
            }
        }
    }
    
    public func fetchEntity<T: NSManagedObject>(entityName: String,
                            predicate: NSPredicate? = nil,
                            sortDescriptor: NSSortDescriptor? = nil,
                            pageSize: Int = 0,
                            pageIndex: Int = 0) -> [T]? {
        
        let fetchRequest = NSFetchRequest(entityName: entityName)
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = sortDescriptor == nil ? nil : [sortDescriptor!]
        
        if pageSize > 0 {
            fetchRequest.fetchLimit = pageSize
            fetchRequest.fetchOffset = pageSize * pageIndex
        }
        
        do {
            let items = try managedObjectContext.executeFetchRequest(fetchRequest) as? [T]
            return items
        }
        catch let error as NSError {
            Log.error?.message("fetch fail, \(error.localizedDescription)")
        }
        
        return nil
    }
    
    public func fetchOneEntity<T: NSManagedObject>(entityName: String,
                               predicate: NSPredicate? = nil,
                               sort sortDescriptor: NSSortDescriptor? = nil,
                                    completion: (item: T?, error: NSError?)->Void ) {
        
        let fetchRequest = NSFetchRequest(entityName: entityName)
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = (sortDescriptor != nil ? [sortDescriptor!] : nil)
        fetchRequest.fetchLimit = 1
        
        let moc = currentManagedObjectContext
        moc.performBlock { 
            do {
                let item = try moc.executeFetchRequest(fetchRequest)
                if let results = item as? [T], result = results.first {
                    completion(item: result, error: nil)
                }
                else {
                    completion(item: nil, error: self.castError(NSStringFromClass(T)))
                }
            }
            catch let error as NSError {
                completion(item: nil, error: error)
            }
        }
    }
    
    public func fetchOneEntity<T: NSManagedObject>(entityName: String,
                               predicate: NSPredicate? = nil,
                               sort sortDescriptor: NSSortDescriptor? = nil ) -> T? {
        
        let fetchRequest = NSFetchRequest(entityName: entityName)
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = (sortDescriptor != nil ? [sortDescriptor!] : nil)
        fetchRequest.fetchLimit = 1
        
        do {
            let result = try managedObjectContext.executeFetchRequest(fetchRequest) as? [T]
            return result?.first
        }
        catch let error as NSError {
            Log.error?.message("fetch error \(error.localizedDescription)")
            return nil
        }
    }
    
//    public func removeAllEntity(entityName: String, predicate: NSPredicate? = nil) {
//        guard let items = fetchEntity(entityName, predicate: predicate) else { return }
//        
//        for item in items {
//            managedObjectContext.deleteObject(item)
//        }
//        
//        do {
//            try managedObjectContext.save()
//        }
//        catch let error as NSError {
//            print("save fail \(error.localizedDescription)")
//        }
//    }
    
    public func removeAllEntity(entityName: String, predicate: NSPredicate? = nil) {
        guard let items = fetchEntity(entityName, predicate: predicate) else { return }
        
        for item in items {
            managedObjectContext.deleteObject(item)
        }
        
        do {
            try managedObjectContext.save()
        }
        catch let error as NSError {
            print("save fail \(error.localizedDescription)")
        }
    }
    
    public func insertOrUpdateEntity<T: NSManagedObject>(entityName: String, predicate: NSPredicate, itemHandler: ((item: T) -> Void)) -> Bool {
        
        if let existItem: T = fetchOneEntity(entityName, predicate: predicate) {
            itemHandler(item: existItem)
            return true
        }
        else {
            guard let newItem = NSEntityDescription.insertNewObjectForEntityForName(entityName, inManagedObjectContext: managedObjectContext) as? T
                else { return false }
            
            itemHandler(item: newItem)
            
            do {
                try managedObjectContext.save()
            }
            catch let error as NSError {
                print("save failed \(error.localizedDescription)")
                return false
            }
            
            return true
        }
    }
    
    private func castError(className: String) -> NSError {
        let desc = NSLocalizedString("Cast to \(className) was unsuccessful.", comment: "Cast Error")
        let userInfo = [NSLocalizedDescriptionKey: desc]
        return NSError(domain: "DBHelperDomain", code: -1, userInfo: userInfo)
    }
}

