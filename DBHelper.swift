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

struct MWDBHelper {
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
    
    init(managedObjectContext: NSManagedObjectContext, mergePolicy: AnyObject = NSMergeByPropertyObjectTrumpMergePolicy){
        self.managedObjectContext = managedObjectContext
        self.mergePolicy = mergePolicy
    }

    func countForEntity(entityName: String, predicate: NSPredicate? = nil, completion: ((Int, NSError?)->Void)?) {

        let moc = currentManagedObjectContext
        moc.performBlock {
            var error: NSError? = nil
            let count = moc.countForFetchRequest(self.countForEntity(entityName, predicate: predicate), error: &error)
            completion?(count, error)
        }
    }
    
    func countForEntity(entityName: String, predicate: NSPredicate? = nil) -> Int? {
        
        var result: Int? = nil
        managedObjectContext.performBlockAndWait { 
            var error: NSError? = nil
            
            result = self.managedObjectContext.countForFetchRequest(self.countForEntity(entityName, predicate: predicate), error: &error)
            if let error = error {
                Log.error?.message("fetch count fail, \(error.localizedDescription)")
            }
        }
        
        return result
    }
    
    
    func fetchEntity<T: NSManagedObject>(entityName: String,
                            predicate: NSPredicate? = nil,
                            sort: NSSortDescriptor? = nil,
                            pageSize: Int = 0,
                            pageIndex: Int = 0,
                            completion: (([T]?, NSError?)->Void)?) {
        
        let fetchRequest = fetchForEntity(entityName, predicate: predicate, sort: sort, pageSize: pageSize, pageIndex: pageIndex)
        
        let moc = currentManagedObjectContext
        moc.performBlock {
            do {
                let items = try moc.executeFetchRequest(fetchRequest)
                if let items = items as? [T] {
                    completion?(items, nil)
                }
                else {
                    let error = self.castError(NSStringFromClass(T))
                    completion?(nil, error)
                }
            }
            catch let error as NSError {
                Log.error?.message("concurrent fetch fail, \(error.localizedDescription)")
                completion?(nil, error)
            }
        }
    }
    
    func fetchEntity<T: NSManagedObject>(entityName: String,
                            predicate: NSPredicate? = nil,
                            sort: NSSortDescriptor? = nil,
                            pageSize: Int = 0,
                            pageIndex: Int = 0) -> [T]? {
        
        let fetchRequest = fetchForEntity(entityName, predicate: predicate, sort: sort, pageSize: pageSize, pageIndex: pageIndex)
        
        let moc = currentManagedObjectContext
        
        var items : [T]? = nil
        
        moc.performBlockAndWait { 
            do {
                items = try moc.executeFetchRequest(fetchRequest) as? [T]
            }
            catch let error as NSError {
                Log.error?.message("fetch fail, \(error.localizedDescription)")
            }
        }

        return items
    }
    
    func fetchOneEntity<T: NSManagedObject>(entityName: String,
                               predicate: NSPredicate? = nil,
                               sort: NSSortDescriptor? = nil,
                               completion: ((T?, NSError?)->Void)? ) {
        
        let completionWrapper: ([T]?, NSError?)->Void = { (items, error) in
            completion?(items?.first, error)
        }
        
        fetchEntity(entityName, predicate: predicate, sort: sort, pageSize: 1, completion: completionWrapper)
    }
    
    func fetchOneEntity<T: NSManagedObject>(entityName: String,
                               predicate: NSPredicate? = nil,
                               sort: NSSortDescriptor? = nil ) -> T? {
        
        guard let items:[T] = fetchEntity(entityName, predicate: predicate, sort: sort, pageSize: 0) else { return nil }
        return items.first
    }
    
    func removeAllEntity(entityName: String,
                         predicate: NSPredicate? = nil,
                         completion: ((error: NSError?)->Void)?) {
        
        let moc = currentManagedObjectContext
        fetchEntity(entityName, predicate: predicate) { (items, error) in
            
            guard let items = items else { completion?(error: nil); return }
            
            for item in items {
                moc.deleteObject(item)
            }
            
            self.saveThreadContext(moc, completion: completion)
        }
    }
    
    func removeAllEntity(entityName: String, predicate: NSPredicate? = nil) -> Bool {
        guard let items = fetchEntity(entityName, predicate: predicate) else { return true }
        
        let moc = currentManagedObjectContext
        
        moc.performBlockAndWait {
            for item in items {
                moc.deleteObject(item)
            }
        }
        
        return saveThreadContext(moc)
    }
    
    func insertOrUpdateOneEntity<T: NSManagedObject>(entityName: String,
                                     predicate: NSPredicate,
                                     itemHandler: ((item: T) -> Void),
                                     completion: ((error: NSError?)->Void)?) {
        
        let moc = currentManagedObjectContext
        
        fetchOneEntity(entityName, predicate: predicate) { (item:T?, error) in
            if let item = item {
                itemHandler(item: item)
                self.saveThreadContext(moc, completion: completion)
            }
            else {
                guard let newItem = NSEntityDescription.insertNewObjectForEntityForName(entityName, inManagedObjectContext: moc) as? T
                    else { completion?(error: self.castError(NSStringFromClass(T))); return }
                itemHandler(item: newItem)
                
                self.saveThreadContext(moc, completion: completion)
            }
        }
    }
    
    func insertOrUpdateOneEntity<T: NSManagedObject>(entityName: String, predicate: NSPredicate, itemHandler: ((item: T) -> Void)) -> Bool {
        
        let moc = currentManagedObjectContext
        
        moc.performBlockAndWait { 
            if let existItem: T = self.fetchOneEntity(entityName, predicate: predicate) {
                itemHandler(item: existItem)
            }
            else {
                guard let newItem = NSEntityDescription.insertNewObjectForEntityForName(entityName, inManagedObjectContext: moc) as? T
                    else { return }
                
                itemHandler(item: newItem)
            }
        }
        
        return saveThreadContext(moc)
    }
    
    func saveContext () -> Bool {
        if !managedObjectContext.hasChanges {
            return true
        }
        
        do {
            try managedObjectContext.save()
            return true
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nserror = error as NSError
            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            return false
        }
    }
    
    func saveThreadContext(moc: NSManagedObjectContext) -> Bool {
        var result = false
        
        moc.mergePolicy = mergePolicy
        
        
        moc.performBlockAndWait {
            if !moc.hasChanges {
                return
            }
            
            do {
                try moc.save()
                result = true
                dispatch_async(dispatch_get_main_queue(), {
                    self.saveContext()
                })
            }
            catch {
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
        
        return result
    }
    
    func saveThreadContext(context: NSManagedObjectContext, completion: ((error: NSError?)->Void)?) {
        let managedObjectContext = context
        managedObjectContext.mergePolicy = mergePolicy
        managedObjectContext.performBlock {
            
            if !managedObjectContext.hasChanges {
                completion?(error: nil)
                return
            }
            
            do {
                try managedObjectContext.save()

                dispatch_async(dispatch_get_main_queue(), {
                    self.saveContext()
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                        completion?(error: nil)
                    })
                })
            }
            catch {
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                completion?(error: nserror)
            }
        }
    }
    

}

private extension MWDBHelper {
    
    func countForEntity(entityName: String, predicate: NSPredicate?) -> NSFetchRequest {
        let fetchRequest = NSFetchRequest(entityName: entityName)
        fetchRequest.predicate = predicate
        return fetchRequest
    }
    
    func fetchForEntity(entityName: String,
                        predicate: NSPredicate? = nil,
                        sort: NSSortDescriptor? = nil,
                        pageSize: Int = 0,
                        pageIndex: Int = 0) -> NSFetchRequest {
            
        let fetchRequest = NSFetchRequest(entityName: entityName)
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = sort == nil ? nil : [sort!]
        
        if pageSize > 0 {
            fetchRequest.fetchLimit = pageSize
            fetchRequest.fetchOffset = pageSize * pageIndex
        }
        
        return fetchRequest
    }
    
    func castError(className: String) -> NSError {
        let desc = NSLocalizedString("Cast to \(className) was unsuccessful.", comment: "Cast Error")
        let userInfo = [NSLocalizedDescriptionKey: desc]
        return NSError(domain: "DBHelperDomain", code: -1, userInfo: userInfo)
    }
}
