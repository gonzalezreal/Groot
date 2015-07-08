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
        
        XCTAssertFalse(transformer.dynamicType.allowsReverseTransformation(), "should not allow reverse transformation")
        XCTAssertEqual("42", transformer.transformedValue(42) as! String, "should call the transform function")
        XCTAssertNil(transformer.transformedValue(nil), "should handle nil values")
        XCTAssertNil(transformer.transformedValue("unexpected"), "should handle unsupported values")
    }
    
    func testReversibleValueTransformer() {
        func toString(value: Int) -> String? {
            return "\(value)"
        }
        
        func toInt(value: String) -> Int? {
            return value.toInt()
        }
        
        NSValueTransformer.setValueTransformerWithName("testReversibleTransformer", transform: toString, reverseTransform: toInt)
        let transformer = NSValueTransformer(forName: "testReversibleTransformer")!
        
        XCTAssertTrue(transformer.dynamicType.allowsReverseTransformation(), "should not allow reverse transformation")
        XCTAssertEqual("42", transformer.transformedValue(42) as! String, "should call the transform function")
        XCTAssertNil(transformer.transformedValue(nil), "should handle nil values")
        XCTAssertNil(transformer.transformedValue("unexpected"), "should handle unsupported values")
        XCTAssertEqual(42, transformer.reverseTransformedValue("42") as! Int, "should call the reverse transform function")
        XCTAssertNil(transformer.reverseTransformedValue(nil), "should handle nil values")
        XCTAssertNil(transformer.reverseTransformedValue("not a number"), "should handle unsupported values")
    }

}
