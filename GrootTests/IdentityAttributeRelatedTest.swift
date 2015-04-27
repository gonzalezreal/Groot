//
//  IdentityAttributeRelatedTest.swift
//  Groot
//
//  Created by Manue on 23/4/15.
//  Copyright (c) 2015 Guille Gonzalez. All rights reserved.
//

import UIKit
import XCTest
import CoreData
import Groot

class IdentityAttributeRelatedTest: XCTestCase {

	var store: ManagedStore?
	var context: NSManagedObjectContext?
	
	override func setUp() {
		super.setUp()
		
		let bundle = NSBundle(forClass: IdentityAttributeRelatedTest.self)
		let modelURL = bundle.URLForResource("IdentityRelatedModel", withExtension: "momd")!
		let model = NSManagedObjectModel(contentsOfURL: modelURL)!
		store = ManagedStore(model: model, error: nil)
		XCTAssertNotNil(store)
		
		context = store?.contextWithConcurrencyType(.MainQueueConcurrencyType)
		XCTAssertNotNil(context)
	}
	
	override func tearDown() {
		context = nil
		store = nil
		
		super.tearDown()
	}
	
	func testMergeObjectsWithToOneRelationshipIdentityAttributeRelated() {
		
		let batmanJSON = [
			"id": "1",
			"name": "Batman",
			"publisher": "1"
		]
		
		
		let batman = IARCharacter.fromJSONObject(batmanJSON, inContext: context!, mergeChanges: true, error: nil)
		
		let publisherJSONArray = [
			[
				"id": "1",
				"name": "DC"
			],
			[
				"id": "2",
				"name": "Marvel"]
		]
		
		let characters: [IARPublisher]? = importJSONArray(publisherJSONArray, inContext: context!, mergeChanges: true, error: nil)
		
		XCTAssertEqual(batman!.publisher!.name, "DC", "should serialize relationship")
		
	}
	
	func testMergeObjectsWithToManyRelationshipIdentityAttributeRelated() {
		
		let dcJSON: JSONObject = [
			"id": "1",
			"name": "DC",
			"characters": [
				"1",
				"2",
				"4"
			]
		]
		
		let dc = IARPublisher.fromJSONObject(dcJSON, inContext: context!, mergeChanges: true, error: nil)
		
		let charactersJSONArray = [
			[
				"id": "1",
				"name": "Batman"
			],
			[
				"id": "2",
				"name": "Superman"
			],
			[
				"id": "3",
				"name": "Spiderman"
			],
			[
				"id": "4",
				"name": "Aquaman"
			]
		]
		
		let characters: [IARCharacter]? = importJSONArray(charactersJSONArray, inContext: context!, mergeChanges: true, error: nil)
		
		let expectedSet = Set(["Batman", "Superman", "Aquaman"])
		let receivedSet = dc!.characters!.valueForKey("name") as! Set<String>
		
		XCTAssertEqual(expectedSet, receivedSet, "should serialize relationship")
	}
	
	func testJSONDictionaryFromManagedObjectWithToOneRelationshipIdentityAttributeRelated() {
		
		let dc = NSEntityDescription.insertNewObjectForEntityForName("IARPublisher", inManagedObjectContext: context!) as! IARPublisher
		dc.identifier = "1"
		dc.name = "DC"
		
		let batman = NSEntityDescription.insertNewObjectForEntityForName("IARCharacter", inManagedObjectContext: context!) as! IARCharacter
		batman.name = "Batman"
		batman.identifier = "1"
		batman.publisher = dc
		
		let batmanJSON = batman.toJSONObject() as JSONObject
		
		XCTAssertEqual(batmanJSON["publisher"] as! String, "1", "should create right JSON")
		
	}
	
	func testJSONDictionaryFromManagedObjectWithToManyRelationshipIdentityAttributeRelated() {
		
		let dc = NSEntityDescription.insertNewObjectForEntityForName("IARPublisher", inManagedObjectContext: context!) as! IARPublisher
		dc.identifier = "1"
		dc.name = "DC"
		
		let batman = NSEntityDescription.insertNewObjectForEntityForName("IARCharacter", inManagedObjectContext: context!) as! IARCharacter
		batman.name = "Batman"
		batman.identifier = "1"
		batman.publisher = dc
		
		let superman = NSEntityDescription.insertNewObjectForEntityForName("IARCharacter", inManagedObjectContext: context!) as! IARCharacter
		superman.name = "Superman"
		superman.identifier = "2"
		superman.publisher = dc
		
		let dcJSON = dc.toJSONObject() as JSONObject
		let actualSet = Set(dcJSON["characters"] as! [String])
		let expectedSet = Set(["1", "2"])
		
		XCTAssertEqual(actualSet, expectedSet, "should create right JSON")
		
	}
	
}
