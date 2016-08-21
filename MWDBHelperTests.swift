//
//  MWDBHelperTests.swift
//  SwiftUtilExample
//
//  Created by wizard lee on 8/20/16.
//  Copyright © 2016 wizard lee. All rights reserved.
//

import XCTest
import CoreData
import CleanroomLogger

@testable import SwiftUtilExample

class MWDBHelperTests: XCTestCase {
    
    lazy var manageObjectContext: NSManagedObjectContext = {
        (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    }()
    
    var dbHelper: MWDBHelper!
    
    override func setUp() {
        super.setUp()
        if (dbHelper == nil) {
            dbHelper = MWDBHelper(manageObjectContext: manageObjectContext)
        }
    }
    
    override func tearDown() {
        super.tearDown()
        dbHelper.removeAllEntity("TestItem")
    }
    
    func testRemoveAllEntity() {
        for _ in 0..<3 {
            insertOneItem()
        }
        
        let entityName = "TestItem"
        let count = dbHelper.countForEntity(entityName)
        XCTAssertNotEqual(count, 0)
        
        dbHelper.removeAllEntity(entityName)
        let count2 = dbHelper.countForEntity(entityName)
        XCTAssertEqual(count2, 0)
    }
    
    func testCountForEntity() {
        insertOneItem()
        
        let count = dbHelper.countForEntity("TestItem")
        XCTAssertEqual(count, 1)
        
        for _ in 0..<2 {
            insertOneItem()
        }
        
        let count2 = dbHelper.countForEntity("TestItem")
        XCTAssertEqual(count2, 3)
    }
    
    func insertOneItem() {
        let newItem = NSEntityDescription.insertNewObjectForEntityForName("TestItem", inManagedObjectContext: manageObjectContext) as! TestItem
        newItem.name = "hello"
        do {
            try manageObjectContext.save()
        }
        catch let error as NSError {
            print("insert fail \(error.localizedDescription)")
        }
    }
    
    func testFetchEntity() {
        insertOneItem()
        
        let items = dbHelper.fetchEntity("TestItem")
        XCTAssertNotNil(items)
        XCTAssertTrue(items!.count != 0)
    }
    
    func testFetchOneEntity() {
        insertOneItem()
        
        let value: TestItem? = dbHelper.fetchOneEntity("TestItem")
        XCTAssertNotNil(value)
    }
    
    func testFetchOneEntityWithPredicate() {
        insertOneItem()
        
        let predicate = NSPredicate(format: "name = %@", "hello")
        let item = dbHelper.fetchOneEntity("TestItem", predicate: predicate)
        XCTAssertNotNil(item)
        
        let predicate2 = NSPredicate(format: "name = %@", "world")
        let item2 = dbHelper.fetchOneEntity("TestItem", predicate: predicate2)
        XCTAssertNil(item2)
    }
    
    func testInsertOrUpdate() {
        let predicate = NSPredicate(format: "name = %@", "hello")
        
        dbHelper.insertOrUpdateEntity("TestItem", predicate: predicate) { (item : TestItem) in
            item.name = "hello"
        }
        
        let count = dbHelper.countForEntity("TestItem", predicate: predicate)
        XCTAssertEqual(count, 1)
        
        dbHelper.insertOrUpdateEntity("TestItem", predicate: predicate) { (item : TestItem) in
            item.name = "hello"
        }
        
        let count2 = dbHelper.countForEntity("TestItem", predicate: predicate)
        XCTAssertEqual(count2, 1)
        
        insertOneItem()
        let count3 = dbHelper.countForEntity("TestItem", predicate: predicate)
        Log.info?.message("count3 : \(count3 ?? 0)")
        XCTAssertEqual(count3, 2)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
}
