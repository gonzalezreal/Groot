//
//  NSPropertyDescription+Groot.swift
//  Groot
//
//  Created by Guille Gonzalez on 29/03/15.
//  Copyright (c) 2015 Guille Gonzalez. All rights reserved.
//

import CoreData

public let JSONKeyPathKey = "JSONKeyPath"

extension NSPropertyDescription {
    
    /// The JSON key path.
    internal var JSONKeyPath: String? {
        return userInfo?[Groot.JSONKeyPathKey] as? String
    }
    
    /// Returns `true` if this property should participate in the JSON serialization process.
    internal var JSONSerializable: Bool {
        return JSONKeyPath != nil
    }
    
    /// Returns the untransformed raw value for this property in a given JSON object
    internal func rawValueInJSONObject(object: JSONObject) -> AnyObject? {
        if let keyPath = JSONKeyPath {
            return (object as NSDictionary).valueForKeyPath(keyPath)
        }
        
        return nil
    }
}

