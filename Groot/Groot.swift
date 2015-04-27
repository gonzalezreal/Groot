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
    let entity = T.entityInManagedObjectContext(context)
    return entity.importJSONObject(object, inContext: context, mergeChanges: mergeChanges, error: outError) as? T
}

/// Creates an array of managed objects by importing the given JSON array.
public func importJSONArray<T: NSManagedObject>(array: JSONArray, inContext context: NSManagedObjectContext, #mergeChanges: Bool, error outError: NSErrorPointer) -> [T]? {
    let entity = T.entityInManagedObjectContext(context)
    return entity.importJSONArray(array, inContext: context, mergeChanges: mergeChanges, error: outError) as? [T]
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

private func managedObjectCast<T: NSManagedObject>(object: AnyObject) -> T {
    return object as! T
}

extension NSManagedObject {
    /// Creates an instance of the receiver by importing the given JSON object.
    public class func fromJSONObject(object: JSONObject, inContext context: NSManagedObjectContext, mergeChanges: Bool, error outError: NSErrorPointer) -> Self? {
        return importJSONObject(object, inContext: context, mergeChanges: mergeChanges, error: outError)
    }
    
    /// Returns a JSON representation of the receiver.
    public func toJSONObject() -> JSONObject {
        // Keeping track of in process relationships avoids infinite recursion when serializing inverse relationships
        var processingRelationships = Set<NSRelationshipDescription>()
        
        return toJSONObject(processingRelationships: &processingRelationships)
    }
    
    /// Creates an instance of the receiver and inserts it in a given managed object context.
    public class func insertInManagedObjectContext(context: NSManagedObjectContext) -> Self {
        let entity = self.entityInManagedObjectContext(context)
        let object: AnyObject = NSEntityDescription.insertNewObjectForEntityForName(entity.name!, inManagedObjectContext: context)
        
        return managedObjectCast(object)
    }
}
