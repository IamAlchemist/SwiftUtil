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
    
    public init(manageObjectContext: NSManagedObjectContext){
        self.managedObjectContext = manageObjectContext
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
    
    public func fetchEntity(entityName: String,
                            predicate: NSPredicate? = nil,
                            sortDescriptor: NSSortDescriptor? = nil,
                            pageSize: Int = 0,
                            pageIndex: Int = 0) -> [NSManagedObject]? {
        
        let fetchRequest = NSFetchRequest(entityName: entityName)
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = sortDescriptor == nil ? nil : [sortDescriptor!]
        
        if pageSize > 0 {
            fetchRequest.fetchLimit = pageSize
            fetchRequest.fetchOffset = pageSize * pageIndex
        }
        
        do {
            let items = try managedObjectContext.executeFetchRequest(fetchRequest) as? [NSManagedObject]
            return items
        }
        catch let error as NSError {
            Log.error?.message("fetch fail, \(error.localizedDescription)")
        }
        
        return nil
    }
    
    public func fetchOneEntity<T: NSManagedObject>(entityName: String, predicate: NSPredicate? = nil, sort sortDescriptor: NSSortDescriptor? = nil ) -> T? {
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
}

