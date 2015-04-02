//
//  Groot.swift
//  Groot
//
//  Created by Guille Gonzalez on 28/03/15.
//  Copyright (c) 2015 Guille Gonzalez. All rights reserved.
//

import CoreData

public typealias JSONObject = [String: AnyObject]
public typealias JSONArray = [AnyObject]

/// Creates a managed object by importing the given JSON object.
public func importJSONObject<T: NSManagedObject>(object: JSONObject, inContext context: NSManagedObjectContext, #mergeChanges: Bool, error outError: NSErrorPointer) -> T? {
    if let entity = T.entityInManagedObjectContext(context, error: outError) {
        return entity.importJSONObject(object, inContext: context, mergeChanges: mergeChanges, error: outError) as? T
    }
    
    return nil
}

/// Creates an array of managed objects by importing the given JSON array.
public func importJSONArray<T: NSManagedObject>(array: JSONArray, inContext context: NSManagedObjectContext, #mergeChanges: Bool, error outError: NSErrorPointer) -> [T]? {
    if let entity = T.entityInManagedObjectContext(context, error: outError) {
        return entity.importJSONArray(array, inContext: context, mergeChanges: mergeChanges, error: outError) as? [T]
    }
    
    return nil
}

/// Creates an array of managed objects by importing the given JSON data.
public func importJSONData<T: NSManagedObject>(data: NSData, inContext context: NSManagedObjectContext, #mergeChanges: Bool, error outError: NSErrorPointer) -> [T]? {
    if let parsedJSON: AnyObject = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(0), error: outError) {
        switch (parsedJSON) {
        case let object as JSONObject:
            return importJSONArray([object], inContext: context, mergeChanges: mergeChanges, error: outError)
        case let array as JSONArray:
            return importJSONArray(array, inContext: context, mergeChanges: mergeChanges, error: outError)
        default:
            break
        }
    }
    
    return nil
}

extension NSManagedObject {
    /// Creates an instance of the receiver by importing the given JSON object.
    public class func fromJSONObject(object: JSONObject, inContext context: NSManagedObjectContext, mergeChanges: Bool, error outError: NSErrorPointer) -> Self? {
        return importJSONObject(object, inContext: context, mergeChanges: mergeChanges, error: outError)
    }
}
