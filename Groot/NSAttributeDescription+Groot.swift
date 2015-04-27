//
//  NSAttributeDescription+Groot.swift
//  Groot
//
//  Created by Guille Gonzalez on 29/03/15.
//  Copyright (c) 2015 Guille Gonzalez. All rights reserved.
//

import CoreData

public let JSONTransformerNameKey = "JSONTransformerName"

extension NSAttributeDescription {
    
    /// The value transformer for this attribute.
    internal var JSONTransformer: NSValueTransformer? {
        return (userInfo?[Groot.JSONTransformerNameKey] as? String).flatMap {
            NSValueTransformer(forName: $0)
        }
    }
    
    /// Returns the value for this attribute in a given JSON object
    internal func valueInJSONObject(object: JSONObject) -> AnyObject? {
        if let value: AnyObject = rawValueInJSONObject(object) {
            if value is NSNull {
                return nil
            }
            
            if let transformer = JSONTransformer {
                return transformer.transformedValue(value)
            }
            
            return value
        }
        
        return nil
    }
    
    /// Returns all the values for this attribute in a given JSON array
    internal func valuesInJSONArray(array: JSONArray) -> [AnyObject] {
        var values: [AnyObject] = []
        
        for o in array {
            if let object = o as? JSONObject, value: AnyObject = valueInJSONObject(object) {
                values.append(value)
            }
        }
        
        return values
    }
}

