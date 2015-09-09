// Groot.swift
//
// Copyright (c) 2015 Guillermo Gonzalez
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import CoreData

extension NSManagedObjectContext {
    internal func managedObjectModel() -> NSManagedObjectModel {
        if let psc = persistentStoreCoordinator {
            return psc.managedObjectModel
        }
        
        return parentContext!.managedObjectModel()
    }
}

extension NSManagedObject {
    internal class func entityInManagedObjectContext(context: NSManagedObjectContext) -> NSEntityDescription {
        let className = NSStringFromClass(self)
        let model = context.managedObjectModel()
        
        for entity in model.entities {
            if entity.managedObjectClassName == className {
                return entity
            }
        }
        
        fatalError("Could not locate the entity for \(className).")
    }
}

/**
 Creates or updates a set of managed objects from JSON data.
 
 - parameter entityName: The name of an entity.
 - parameter fromJSONData: A data object containing JSON data.
 - parameter inContext: The context into which to fetch or insert the managed objects.
 
 - returns: An array of managed objects
 */
public func objectsWithEntityName(name: String, fromJSONData data: NSData, inContext context: NSManagedObjectContext) throws -> [NSManagedObject] {
    return try GRTJSONSerialization.objectsWithEntityName(name, fromJSONData: data, inContext: context)
}

/**
 Creates or updates a set of managed objects from JSON data.

 - parameter fromJSONData: A data object containing JSON data.
 - parameter inContext: The context into which to fetch or insert the managed objects.
 
 - returns: An array of managed objects.
 */
public func objectsFromJSONData<T: NSManagedObject>(data: NSData, inContext context: NSManagedObjectContext) throws -> [T] {
    let entity = T.entityInManagedObjectContext(context)
    let managedObjects = try objectsWithEntityName(entity.name!, fromJSONData: data, inContext: context)
    
    return managedObjects as! [T]
}

public typealias JSONDictionary = [String: AnyObject]

/**
 Creates or updates a managed object from a JSON dictionary.
 
 This method converts the specified JSON dictionary into a managed object of a given entity.
 
 - parameter entityName: The name of an entity.
 - parameter fromJSONDictionary: A dictionary representing JSON data.
 - parameter inContext: The context into which to fetch or insert the managed objects.
 
 - returns: A managed object.
 */
public func objectWithEntityName(name: String, fromJSONDictionary dictionary: JSONDictionary, inContext context: NSManagedObjectContext) throws -> NSManagedObject {
    return try GRTJSONSerialization.objectWithEntityName(name, fromJSONDictionary: dictionary, inContext: context)
}

/**
 Creates or updates a managed object from a JSON dictionary.
 
 This method converts the specified JSON dictionary into a managed object.

 - parameter fromJSONDictionary: A dictionary representing JSON data.
 - parameter inContext: The context into which to fetch or insert the managed objects.
 
 - returns: A managed object.
 */
public func objectFromJSONDictionary<T: NSManagedObject>(dictionary: JSONDictionary, inContext context: NSManagedObjectContext) throws -> T {
    let entity = T.entityInManagedObjectContext(context)
    let managedObject = try objectWithEntityName(entity.name!, fromJSONDictionary: dictionary, inContext: context)
    
    return managedObject as! T
}

public typealias JSONArray = [AnyObject]

/**
 Creates or updates a set of managed objects from a JSON array.
 
 - parameter entityName: The name of an entity.
 - parameter fromJSONArray: An array representing JSON data.
 - parameter context: The context into which to fetch or insert the managed objects.
 
 - returns: An array of managed objects.
 */
public func objectsWithEntityName(name: String, fromJSONArray array: JSONArray, inContext context: NSManagedObjectContext) throws -> [NSManagedObject] {
    return try GRTJSONSerialization.objectsWithEntityName(name, fromJSONArray: array, inContext: context)
}

/**
 Creates or updates a set of managed objects from a JSON array.
 
 - parameter fromJSONArray: An array representing JSON data.
 - parameter context: The context into which to fetch or insert the managed objects.
 
 - returns: An array of managed objects.
 */
public func objectsFromJSONArray<T: NSManagedObject>(array: JSONArray, inContext context: NSManagedObjectContext) throws -> [T] {
    let entity = T.entityInManagedObjectContext(context)
    let managedObjects = try objectsWithEntityName(entity.name!, fromJSONArray: array, inContext: context)
    
    return managedObjects as! [T]
}

/**
 Converts a managed object into a JSON representation.
 
 - parameter object: The managed object to use for JSON serialization.

 :return: A JSON dictionary.
 */
public func JSONDictionaryFromObject(object: NSManagedObject) -> JSONDictionary {
    return GRTJSONSerialization.JSONDictionaryFromObject(object) as! JSONDictionary;
}

/**
 Converts an array of managed objects into a JSON representation.
 
 - parameter objects: The array of managed objects to use for JSON serialization.
 
 :return: A JSON array.
 */
public func JSONArrayFromObjects(objects: [NSManagedObject]) -> JSONArray {
    return GRTJSONSerialization.JSONArrayFromObjects(objects)
}
