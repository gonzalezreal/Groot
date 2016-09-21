//
//  ManagedStoreTests.swift
//  Groot
//
//  Created by Guillermo Gonzalez on 20/09/16.
//  Copyright © 2016 Guillermo Gonzalez. All rights reserved.
//

import XCTest
import Groot

class ManagedStoreTests: XCTestCase {

    var fileURLs: [URL] = []

    override func tearDown() {
        fileURLs.forEach { url in
            try? FileManager.default.removeItem(at: url)
        }

        super.tearDown()
    }
    
    func testInMemoryStore() {
        let model = NSManagedObjectModel.testModel
        guard let store = try? GRTManagedStore(model: model) else {
            XCTFail()
            return
        }

        let persistentStore = store.persistentStoreCoordinator.persistentStores[0]
        XCTAssertEqual(persistentStore.type, NSInMemoryStoreType)
    }

    func testStoreWithCacheName() {
        let model = NSManagedObjectModel.testModel
        guard let store = try? GRTManagedStore(cacheName: "Test.data", model: model) else {
            XCTFail()
            return
        }

        guard
            let bundleIdentifier = Bundle(for: GRTManagedStore.self).bundleIdentifier,
            let url = try? FileManager.default.url(
                for: .cachesDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: false) else {
                    XCTFail()
                    return
        }

        let expectedURL = url.appendingPathComponent("\(bundleIdentifier)/Test.data")
        XCTAssertEqual(store.url, expectedURL)
    }

    func testContextWithConcurrencyType() {
        let model = NSManagedObjectModel.testModel
        guard let store = try? GRTManagedStore(model: model) else {
            XCTFail()
            return
        }

        let context = store.context(with: .mainQueueConcurrencyType)
        XCTAssertEqual(context.persistentStoreCoordinator, store.persistentStoreCoordinator)
        XCTAssertEqual(context.concurrencyType, .mainQueueConcurrencyType)
    }
}
