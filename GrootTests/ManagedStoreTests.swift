//
//  ManagedStoreTests.swift
//  Groot
//
//  Created by Guille Gonzalez on 28/03/15.
//  Copyright (c) 2015 Guille Gonzalez. All rights reserved.
//

import XCTest
import CoreData
import Groot

extension NSManagedObjectModel {
    class func testModel() -> NSManagedObjectModel? {
        let bundle = NSBundle(forClass: Character.self)
        return NSManagedObjectModel.mergedModelFromBundles([bundle])
    }
}

class ManagedStoreTests: XCTestCase {
    var fileURLs: [NSURL] = []
    
    override func tearDown() {
        for URL in fileURLs {
            NSFileManager.defaultManager().removeItemAtURL(URL, error: nil)
        }
        fileURLs = []
        
        super.tearDown()
    }
    
    func testCachesDirectoryURL() {
        let fileManager = NSFileManager.defaultManager()
        let rootURL = fileManager.URLForDirectory(
            .CachesDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: false, error: nil)!
        let bundleIdentifier = NSBundle(forClass: ManagedStore.self).bundleIdentifier!
        let expectedURL = rootURL.URLByAppendingPathComponent(bundleIdentifier)
        let URL = cachesDirectoryURL(error: nil)!
        
        XCTAssertEqual(expectedURL, URL)
        XCTAssertTrue(fileManager.fileExistsAtPath(URL.path!))
    }
    
    func testMemoryStore() {
        let model = NSManagedObjectModel.testModel()
        XCTAssertNotNil(model)
        
        var error: NSError? = nil
        let store = ManagedStore(model: model!, error: &error)
        
        XCTAssertNil(error)
        XCTAssertNotNil(store)
        
        let persistentStore = store!.persistentStoreCoordinator.persistentStores[0] as! NSPersistentStore
        XCTAssertEqual(NSInMemoryStoreType, persistentStore.type)
    }
    
    func testTemporaryStore() {
        let model = NSManagedObjectModel.testModel()
        XCTAssertNotNil(model)
        
        var error: NSError? = nil
        let store = ManagedStore.temporaryStoreWithModel(model!, error: &error)
        
        XCTAssertNil(error)
        XCTAssertNotNil(store)
        
        let path = store!.URL!.path!
        XCTAssertTrue(path.hasPrefix(NSTemporaryDirectory()))
        
        fileURLs.append(store!.URL!)
    }
    
    func testStoreWithCacheName() {
        let model = NSManagedObjectModel.testModel()
        XCTAssertNotNil(model)
        
        var error: NSError? = nil
        let store = ManagedStore.storeWithCacheName("Test.data", model: model!, error: &error)
        
        XCTAssertNil(error)
        XCTAssertNotNil(store)
        
        let expectedURL = cachesDirectoryURL(error: nil)!.URLByAppendingPathComponent("Test.data")
        XCTAssertEqual(expectedURL, store!.URL!)
        
        fileURLs.append(store!.URL!)
    }
    
    func testContextWithConcurrencyType() {
        let model = NSManagedObjectModel.testModel()
        XCTAssertNotNil(model)
        
        var error: NSError? = nil
        let store = ManagedStore(model: model!, error: &error)
        
        XCTAssertNil(error)
        XCTAssertNotNil(store)
        
        let context = store?.contextWithConcurrencyType(.MainQueueConcurrencyType)
        
        XCTAssertNotNil(context)
        XCTAssertEqual(store!.persistentStoreCoordinator, context!.persistentStoreCoordinator!)
        XCTAssertEqual(.MainQueueConcurrencyType, context!.concurrencyType)
    }
}
