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
        let entities = model.entities as! [NSEntityDescription]
        
        for entity in entities {
            if entity.managedObjectClassName == className {
                return entity
            }
        }
        
        assert(false, "Could not locate the entity for \(className).")
        return NSEntityDescription()
    }
}

/**
 Creates or updates a set of managed objects from JSON data.
 
 :param: entityName The name of an entity.
 :param: fromJSONData A data object containing JSON data.
 :param: inContext The context into which to fetch or insert the managed objects.
 :param: error If an error occurs, upon return contains an NSError object that describes the problem.
 
 :return: An array of managed objects, or `nil` if an error occurs.
 */
public func objectsWithEntityName(name: String, fromJSONData data: NSData, inContext context: NSManagedObjectContext, error outError: NSErrorPointer) -> [NSManagedObject]? {
    return GRTJSONSerialization.objectsWithEntityName(name, fromJSONData: data, inContext: context, error: outError) as? [NSManagedObject]
}

/**
 Creates or updates a set of managed objects from JSON data.

 :param: fromJSONData A data object containing JSON data.
 :param: inContext The context into which to fetch or insert the managed objects.
 :param: error If an error occurs, upon return contains an NSError object that describes the problem.
 
 :return: An array of managed objects, or `nil` if an error occurs.
 */
public func objectsFromJSONData<T: NSManagedObject>(data: NSData, inContext context: NSManagedObjectContext, error outError: NSErrorPointer) -> [T]? {
    let entity = T.entityInManagedObjectContext(context)
    return objectsWithEntityName(entity.name!, fromJSONData: data, inContext: context, error: outError) as? [T]
}

public typealias JSONDictionary = [String: AnyObject]

/**
 Creates or updates a managed object from a JSON dictionary.
 
 This method converts the specified JSON dictionary into a managed object of a given entity.
 
 :param: entityName The name of an entity.
 :param: fromJSONDictionary A dictionary representing JSON data.
 :param: inContext The context into which to fetch or insert the managed objects.
 :param: error If an error occurs, upon return contains an NSError object that describes the problem.
 
 :return: A managed object, or `nil` if an error occurs.
 */
public func objectWithEntityName(name: String, fromJSONDictionary dictionary: JSONDictionary, inContext context: NSManagedObjectContext, error outError: NSErrorPointer) -> NSManagedObject? {
    return GRTJSONSerialization.objectWithEntityName(name, fromJSONDictionary: dictionary, inContext: context, error: outError) as? NSManagedObject
}

/**
 Creates or updates a managed object from a JSON dictionary.
 
 This method converts the specified JSON dictionary into a managed object.

 :param: fromJSONDictionary A dictionary representing JSON data.
 :param: inContext The context into which to fetch or insert the managed objects.
 :param: error If an error occurs, upon return contains an NSError object that describes the problem.
 
 :return: A managed object, or `nil` if an error occurs.
 */
public func objectFromJSONDictionary<T: NSManagedObject>(dictionary: JSONDictionary, inContext context: NSManagedObjectContext, error outError: NSErrorPointer) -> T? {
    let entity = T.entityInManagedObjectContext(context)
    return objectWithEntityName(entity.name!, fromJSONDictionary: dictionary, inContext: context, error: outError) as? T;
}

public typealias JSONArray = [AnyObject]

/**
 Creates or updates a set of managed objects from a JSON array.
 
 :param: entityName The name of an entity.
 :param: fromJSONArray An array representing JSON data.
 :param: context The context into which to fetch or insert the managed objects.
 :param: error If an error occurs, upon return contains an NSError object that describes the problem.
 
 :return: An array of managed objects, or `nil` if an error occurs.
 */
public func objectsWithEntityName(name: String, fromJSONArray array: JSONArray, inContext context: NSManagedObjectContext, error outError: NSErrorPointer) -> [NSManagedObject]? {
    return GRTJSONSerialization.objectsWithEntityName(name, fromJSONArray: array, inContext: context, error: outError) as? [NSManagedObject]
}

/**
 Creates or updates a set of managed objects from a JSON array.
 
 :param: fromJSONArray An array representing JSON data.
 :param: context The context into which to fetch or insert the managed objects.
 :param: error If an error occurs, upon return contains an NSError object that describes the problem.
 
 :return: An array of managed objects, or `nil` if an error occurs.
 */
public func objectsFromJSONArray<T: NSManagedObject>(array: JSONArray, inContext context: NSManagedObjectContext, error outError: NSErrorPointer) -> [T]? {
    let entity = T.entityInManagedObjectContext(context)
    return objectsWithEntityName(entity.name!, fromJSONArray: array, inContext: context, error: outError) as? [T]
}

/**
 Converts a managed object into a JSON representation.
 
 :param: object The managed object to use for JSON serialization.

 :return: A JSON dictionary.
 */
public func JSONDictionaryFromObject(object: NSManagedObject) -> JSONDictionary {
    return GRTJSONSerialization.JSONDictionaryFromObject(object) as! JSONDictionary;
}

/**
 Converts an array of managed objects into a JSON representation.
 
 :param: objects The array of managed objects to use for JSON serialization.
 
 :return: A JSON array.
 */
public func JSONArrayFromObjects(objects: [NSManagedObject]) -> JSONArray {
    return GRTJSONSerialization.JSONArrayFromObjects(objects)
}
