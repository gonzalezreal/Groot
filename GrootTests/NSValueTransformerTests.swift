//
//  NSValueTransformerTests.swift
//  Groot
//
//  Created by Guillermo Gonzalez on 08/07/15.
//  Copyright (c) 2015 Guillermo Gonzalez. All rights reserved.
//

import XCTest
import Groot

class NSValueTransformerTests: XCTestCase {

    func testValueTransformer() {
        func toString(value: Int) -> String? {
            return "\(value)"
        }
        
        NSValueTransformer.setValueTransformerWithName("testTransformer", transform: toString)
        let transformer = NSValueTransformer(forName: "testTransformer")!
        
        let reversible = transformer.dynamicType.allowsReverseTransformation()
        XCTAssertFalse(reversible, "should not allow reverse transformation")
        
        let fortyTwo = transformer.transformedValue(42) as? String
        XCTAssertEqual("42", fortyTwo, "should call the transform function")
        
        let nilValue = transformer.transformedValue(nil)
        XCTAssertNil(nilValue, "should handle nil values")
        
        let unexpected = transformer.transformedValue("unexpected")
        XCTAssertNil(unexpected, "should handle unsupported values")
    }
    
    func testReversibleValueTransformer() {
        func toString(value: Int) -> String? {
            return "\(value)"
        }
        
        func toInt(value: String) -> Int? {
            return Int(value)
        }
        
        NSValueTransformer.setValueTransformerWithName("testReversibleTransformer", transform: toString, reverseTransform: toInt)
        let transformer = NSValueTransformer(forName: "testReversibleTransformer")!
        
        let reversible = transformer.dynamicType.allowsReverseTransformation()
        XCTAssertTrue(reversible, "should allow reverse transformation")
        
        let fortyTwo = transformer.transformedValue(42) as? String
        XCTAssertEqual("42", fortyTwo, "should call the transform function")
        
        let nilValue = transformer.transformedValue(nil)
        XCTAssertNil(nilValue, "should handle nil values")
        
        let unexpected = transformer.transformedValue("unexpected")
        XCTAssertNil(unexpected, "should handle unsupported values")
        
        let reversedFortyTwo = transformer.reverseTransformedValue("42") as? Int
        XCTAssertEqual(42, reversedFortyTwo, "should call the reverse transform function")
        
        let reversedNilValue = transformer.reverseTransformedValue(nil)
        XCTAssertNil(reversedNilValue, "should handle nil values")
        
        let reversedUnexpected = transformer.reverseTransformedValue("not a number")
        XCTAssertNil(reversedUnexpected, "should handle unsupported values")
    }
    
    func testDictionaryTransformer() {
        func preprocessJSONDictionary(dictionary: [String: AnyObject]) -> [String: AnyObject]? {
            var transformedDictionary = dictionary
            transformedDictionary["transformed"] = true
            
            return transformedDictionary
        }
        
        NSValueTransformer.setDictionaryTransformerWithName("testDictionaryTransformer", transform: preprocessJSONDictionary)
        
        let transformer = NSValueTransformer(forName: "testDictionaryTransformer")!
        let transformedDictionary = transformer.transformedValue(["foo": "bar"]) as! [String: AnyObject]
        if let transformed = transformedDictionary["transformed"] as? Bool {
            XCTAssertTrue(transformed, "should call the transform function")
        } else {
            XCTFail("Didn't execute the transform function")
        }
        
        XCTAssertNil(transformer.transformedValue(nil), "should handle nil values")
    }

    func testEntityMapper() {
        func entityForJSONDictionary(dictionary: [String: AnyObject]) -> String? {
            if let type = dictionary["type"] as? String {
                switch type {
                case "A":
                    return "ConcreteA"
                case "B":
                    return "ConcreteB"
                default:
                    return nil
                }
            }
            return nil
        }
        
        NSValueTransformer.setEntityMapperWithName("testEntityMapper", map: entityForJSONDictionary)
        
        let transformer = NSValueTransformer(forName: "testEntityMapper")!
        XCTAssertEqual("ConcreteA", transformer.transformedValue(["type": "A"]) as? String, "should call the transform function")
        XCTAssertEqual("ConcreteB", transformer.transformedValue(["type": "B"]) as? String,  "should call the transform function")
        XCTAssertNil(transformer.transformedValue(nil), "should handle nil values")
    }
}
