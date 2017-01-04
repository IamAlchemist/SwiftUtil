//
//  DBHelper.swift
//
//  Created by wizard lee on 8/20/16.
//  Copyright © 2016 wizard lee. All rights reserved.
//

import Foundation
#if !ASSRC
import CleanroomLogger
#endif
import CoreData

struct MWDBHelper {
    let managedObjectContext: NSManagedObjectContext
    let mergePolicy: AnyObject
    
    private let MOC_KEY : NSString
    
    init(managedObjectContext: NSManagedObjectContext, mergePolicy: AnyObject = NSMergeByPropertyObjectTrumpMergePolicy, moc_key: String = "MWUtil_MOC"){
        self.managedObjectContext = managedObjectContext
        self.mergePolicy = mergePolicy
        self.MOC_KEY = moc_key as! NSString
    }
    
    var currentManagedObjectContext: NSManagedObjectContext {
        get {
            let thisThread = Thread.current
            
            if thisThread == Thread.main {
                return managedObjectContext
            }
            
            if let threadMOC = thisThread.threadDictionary.object(forKey: MOC_KEY) as? NSManagedObjectContext {
                return threadMOC
            }
            else {
                let threadMOC = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
                thisThread.threadDictionary.setObject(threadMOC, forKey: MOC_KEY)
                threadMOC.parent = managedObjectContext
                
                return threadMOC
            }
        }
    }
    
    func countForEntity(entityName: String, predicate: NSPredicate? = nil, completion: ((Int, NSError?)->Void)?) {

        let moc = currentManagedObjectContext
        moc.perform {
            do {
                let count = try moc.count(for: self.countForEntity(entityName: entityName, predicate: predicate))
                completion?(count, nil)
            }
            catch let error as NSError {
                completion?(0, error)
            }
        }
    }
    
    func countForEntity(entityName: String, predicate: NSPredicate? = nil) -> Int? {
        var result: Int? = nil
        managedObjectContext.performAndWait {
            do {
                result = try self.managedObjectContext.count(for: self.countForEntity(entityName: entityName, predicate: predicate))
            }
            catch let error as NSError {
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
        
        let fetchRequest = fetchForEntity(entityName: entityName, predicate: predicate, sort: sort, pageSize: pageSize, pageIndex: pageIndex)
        
        let moc = currentManagedObjectContext
        moc.perform {
            do {
                let items = try moc.fetch(fetchRequest)
                if let items = items as? [T] {
                    completion?(items, nil)
                }
                else {
                    let error = self.castError(className: NSStringFromClass(T.self))
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
        
        let fetchRequest = fetchForEntity(entityName: entityName, predicate: predicate, sort: sort, pageSize: pageSize, pageIndex: pageIndex)
        
        let moc = currentManagedObjectContext
        
        var items : [T]? = nil
        
        moc.performAndWait { 
            do {
                items = try moc.fetch(fetchRequest) as? [T]
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
        
        fetchEntity(entityName: entityName, predicate: predicate, sort: sort, pageSize: 1, pageIndex: 0, completion: completionWrapper)
    }
    
    func fetchOneEntity<T: NSManagedObject>(entityName: String,
                               predicate: NSPredicate? = nil,
                               sort: NSSortDescriptor? = nil ) -> T? {
        
        guard let items:[T] = fetchEntity(entityName: entityName, predicate: predicate, sort: sort, pageSize: 0) else { return nil }
        return items.first
    }
    
    func removeAllEntity(entityName: String,
                         predicate: NSPredicate? = nil,
                         completion: ((_ error: NSError?)->Void)?) {
        
        let moc = currentManagedObjectContext

        fetchEntity(entityName: entityName, predicate: predicate) { (items, error) in
            
            guard let items = items else { completion?(nil); return }
            
            for item in items {
                moc.delete(item)
            }
            
            self.saveThreadContext(context: moc, completion: completion)
        }
    }
    
    func removeAllEntity(entityName: String, predicate: NSPredicate? = nil) -> Bool {
        guard let items = fetchEntity(entityName: entityName, predicate: predicate) else { return true }
        
        let moc = currentManagedObjectContext
        
        moc.performAndWait {
            for item in items {
                moc.delete(item)
            }
        }
        
        return saveThreadContext(moc: moc)
    }
    
    func insertOrUpdateOneEntity<T: NSManagedObject>(entityName: String,
                                     predicate: NSPredicate,
                                     itemHandler: @escaping ((_ item: T) -> Void),
                                     completion: ((_ error: NSError?)->Void)?) {
        
        let moc = currentManagedObjectContext
        
        fetchOneEntity(entityName: entityName, predicate: predicate) { (item:T?, error) in
            if let item = item {
                itemHandler(item)
                self.saveThreadContext(context: moc, completion: completion)
            }
            else {
                guard let newItem = NSEntityDescription.insertNewObject(forEntityName: entityName, into: moc) as? T
                    else { completion?(self.castError(className: NSStringFromClass(T.self))); return }
                itemHandler(newItem)
                
                self.saveThreadContext(context: moc, completion: completion)
            }
        }
    }
    
    func insertOrUpdateOneEntity<T: NSManagedObject>(entityName: String, predicate: NSPredicate, itemHandler: @escaping ((_ item: T) -> Void)) -> Bool {
        
        let moc = currentManagedObjectContext
        
        moc.performAndWait { 
            if let existItem: T = self.fetchOneEntity(entityName: entityName, predicate: predicate) {
                itemHandler(existItem)
            }
            else {
                guard let newItem = NSEntityDescription.insertNewObject(forEntityName: entityName, into: moc) as? T
                    else { return }
                
                itemHandler(newItem)
            }
        }
        
        return saveThreadContext(moc: moc)
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
        
        
        moc.performAndWait {
            if !moc.hasChanges {
                return
            }
            
            do {
                try moc.save()
                result = true
                DispatchQueue.main.async {
                    result = self.saveContext()
                }
            }
            catch {
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
        
        return result
    }
    
    func saveThreadContext(context: NSManagedObjectContext, completion: ((_ error: NSError?)->Void)?) {
        let managedObjectContext = context
        managedObjectContext.mergePolicy = mergePolicy
        managedObjectContext.perform {
            
            if !managedObjectContext.hasChanges {
                completion?(nil)
                return
            }
            
            do {
                try managedObjectContext.save()
                DispatchQueue.main.async {
                    let _ = self.saveContext()
                    DispatchQueue.global(qos: .default).async {
                        completion?(nil)
                    }
                }
            }
            catch {
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                completion?(nserror)
            }
        }
    }
    

}

private extension MWDBHelper {
    
    func countForEntity(entityName: String, predicate: NSPredicate?) -> NSFetchRequest<NSFetchRequestResult> {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        fetchRequest.predicate = predicate
        return fetchRequest
    }
    
    func fetchForEntity(entityName: String,
                        predicate: NSPredicate? = nil,
                        sort: NSSortDescriptor? = nil,
                        pageSize: Int = 0,
                        pageIndex: Int = 0) -> NSFetchRequest<NSFetchRequestResult> {
            
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
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
