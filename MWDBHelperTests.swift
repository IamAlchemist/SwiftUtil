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
    
    let entityName = "TestItem"
    
    lazy var manageObjectContext: NSManagedObjectContext = {
        (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    }()
    
    var dbHelper: MWDBHelper!
    
    override func setUp() {
        super.setUp()
        if (dbHelper == nil) {
            dbHelper = MWDBHelper(managedObjectContext: manageObjectContext)
        }
    }
    
    override func tearDown() {
        super.tearDown()
        dbHelper.removeAllEntity("TestItem")
    }
    
    func testRemoveAllEntityInBack() {
        for _ in 0..<3 {
            insertOneItem()
        }
        
        let expectation = expectationWithDescription("testRemoveAllEntityInBack")
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { 
            let result = self.dbHelper.removeAllEntity(self.entityName)
            XCTAssertTrue(result)
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(2) { (error) in
            if let error = error {
                print("wait error: \(error.localizedDescription)")
            }
        }
    }
    
    func testRemoveAllEntityConcurrent() {
        for _ in 0..<3 {
            insertOneItem()
        }

        let count = dbHelper.countForEntity(entityName)
        XCTAssertNotEqual(count, 0)
        
        let expectation = expectationWithDescription("testRemoveAllEntityConcurrent")
        
        dbHelper.removeAllEntity(entityName) { (error) in
            XCTAssertNil(error)
            
            self.dbHelper.countForEntity(self.entityName, completion: { (count, error) in
                XCTAssertNil(error)
                XCTAssertEqual(count, 0)
                expectation.fulfill()
            })
        }
        
        waitForExpectationsWithTimeout(2) { (error) in
            if let error = error {
                print("wait error: \(error.localizedDescription)")
            }
        }
    }
    
    func testRemoveAllEntity() {
        for _ in 0..<3 {
            insertOneItem()
        }
        
        let count = dbHelper.countForEntity(entityName)
        XCTAssertNotEqual(count, 0)
        
        dbHelper.removeAllEntity(entityName)
        let count2 = dbHelper.countForEntity(entityName)
        XCTAssertEqual(count2, 0)
    }
    
    func testCountForEntityInBack() {
        insertOneItem()
        
        let expectation = expectationWithDescription("testCountForEntityInBack")
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            let count = self.dbHelper.countForEntity(self.entityName)
            XCTAssertNotNil(count)
            XCTAssertEqual(count!, 1)
            expectation.fulfill()
        }

        waitForExpectationsWithTimeout(2) { (error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    func testCountForEntityConcurrent() {
        insertOneItem()
        
        let expectation = expectationWithDescription("testCountForEntityConcurrent1")
        dbHelper.countForEntity(entityName) { (count, error) in
            XCTAssertNil(error)
            XCTAssertEqual(count, 1)
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(2) { (error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }
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
    
    func testFetchEntityInBack() {
        insertOneItem()
        
        let expectation = expectationWithDescription("Test Fetch Entity In Back")
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            let items: [TestItem]? = self.dbHelper.fetchEntity(self.entityName)
            XCTAssertNotNil(items)
            XCTAssertTrue(items!.count != 0)
            
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(2) { (error) in
            if let error = error {
                print("wait error: \(error.localizedDescription)")
            }
        }
    }
    
    func testFetchEntityConcurrent() {
        insertOneItem()
        
        let expectation = expectationWithDescription("Test Fetch Entity Concurrent")
        
        dbHelper.fetchEntity(entityName) { (items, error) in
            XCTAssertNotNil(items)
            XCTAssertNil(error)
            XCTAssertTrue(items!.count != 0)
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(2) { (error) in
            if let error = error {
                print("wait error: \(error.localizedDescription)")
            }
        }
    }
    
    func testFetchEntity() {
        insertOneItem()
        
        let items = dbHelper.fetchEntity("TestItem")
        XCTAssertNotNil(items)
        XCTAssertTrue(items!.count != 0)
    }
    
    func testFetchOneEntityInBack() {
        insertOneItem()
        
        let expectation = expectationWithDescription("Test Fetch One Entity In Back")
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            let item: TestItem? = self.dbHelper.fetchOneEntity(self.entityName)
            XCTAssertNotNil(item)
            XCTAssertNotEqual(NSThread.currentThread(), NSThread.mainThread())
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(2) { (error) in
            if let error = error {
                print("wait error: \(error.localizedDescription)")
            }
        }
    }
    
    func testFetchOneEntityConcurrent() {
        insertOneItem()
        
        let expectation = expectationWithDescription("Test Fetch One Entity Concurrent")
        
        dbHelper.fetchOneEntity(entityName) { (item, error) in
            XCTAssertNil(error)
            XCTAssertNotNil(item)
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(2) { (error) in
            if let error = error {
                print("wait error: \(error.localizedDescription)")
            }
        }
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
    
    func testInsertOrUpdateConcurrent1() {
        let predicate = NSPredicate(format: "name = %@", "hello")
        let entityname = self.entityName
        let handler = { (item: TestItem) in
            item.name = "hello"
        }
        let dbHelper = self.dbHelper
        
        let expectation = expectationWithDescription("testInsertOrUpdateConcurrent1")
        
        dbHelper.insertOrUpdateOneEntity(entityname,
                                      predicate: predicate,
                                      itemHandler: handler)
        { (error) in
            XCTAssertNil(error)
            
            dbHelper.countForEntity(entityname) { (count, error) in
                XCTAssertNil(error)
                XCTAssertEqual(count, 1)
                
                dbHelper.insertOrUpdateOneEntity(entityname,
                                              predicate: predicate,
                                              itemHandler: handler)
                { (error) in
                    XCTAssertNil(error)
                    
                    dbHelper.countForEntity(entityname) { (count, error) in
                        XCTAssertNil(error)
                        XCTAssertEqual(count, 1)
                        
                        expectation.fulfill()
                    }
                }
            }
        }
        
        waitForExpectationsWithTimeout(2) { (error) in
            if let error = error {
                print("wait error: \(error.localizedDescription)")
            }
        }
    }
    
    func testInsertOrUpdate() {
        let predicate = NSPredicate(format: "name = %@", "hello")
        
        dbHelper.insertOrUpdateOneEntity("TestItem", predicate: predicate) { (item : TestItem) in
            item.name = "hello"
        }
        
        let count = dbHelper.countForEntity("TestItem", predicate: predicate)
        XCTAssertEqual(count, 1)
        
        dbHelper.insertOrUpdateOneEntity("TestItem", predicate: predicate) { (item : TestItem) in
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
    
    // MARK: - private    
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
    
    
}
