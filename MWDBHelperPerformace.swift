//
//  MWDBHelperPerformace.swift
//  SwiftUtilExample
//
//  Created by wizard lee on 8/26/16.
//  Copyright © 2016 wizard lee. All rights reserved.
//

import XCTest
import CoreData
import CleanroomLogger

@testable import SwiftUtilExample

class MWDBHelperPerformace: XCTestCase {
    
    let entityName = "TestItem"
    
    lazy var manageObjectContext: NSManagedObjectContext = {
        (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    }()
    
    var dbHelper: MWDBHelper!
    
    override func setUp() {
        super.setUp()
        if (dbHelper == nil) {
            dbHelper = MWDBHelper(managedObjectContext: manageObjectContext)
            MWUtil.setupCleanRoomLogger()
        }
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testFetchEntity() {
        insertOneItem()
        
        let items : [TestItem]? = dbHelper.fetchEntity("TestItem")
        XCTAssertNotNil(items)
        XCTAssertTrue(items!.count != 0)
        Log.info?.message("items count \(items!.count)")
    }
    
    func testPerformance1() {
        // This is an example of a performance test case.
        self.measureBlock {
            let item : TestItem? = self.dbHelper.fetchOneEntity(self.entityName)
            XCTAssertNotNil(item)
        }
    }
    
    func testPerformance2() {
        // This is an example of a performance test case.
        self.measureBlock {
            let item : TestItem? = self.dbHelper.fetchOneEntity(self.entityName)
            XCTAssertNotNil(item)
        }
    }
    
}

private extension MWDBHelperPerformace {
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
