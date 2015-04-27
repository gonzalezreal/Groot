//
//  NSEntityDescription+Groot.swift
//  Groot
//
//  Created by Guille Gonzalez on 29/03/15.
//  Copyright (c) 2015 Guille Gonzalez. All rights reserved.
//

import CoreData

public let identityAttributeKey = "identityAttribute"

extension NSEntityDescription {
    /// The identity attribute for this entity
    internal var identityAttribute: NSAttributeDescription? {
        var attributeName: String? = nil
        var entity: NSEntityDescription? = self
        
        while (entity != nil) && (attributeName == nil) {
            attributeName = entity?.userInfo?[Groot.identityAttributeKey] as? String
            entity = entity?.superentity
        }
        
        return attributeName.flatMap {
            attributesByName[$0] as? NSAttributeDescription
        }
    }
    
    /// Returns the identifier value in a given JSON object
    internal func identifierInJSONObject(object: JSONObject) -> AnyObject? {
        return identityAttribute.flatMap {
            return $0.valueInJSONObject(object)
        }
    }
    
    /// Returns the existing objects in a given context. Requires an identity attribute.
    internal func existingObjectsWithJSONArray(array: JSONArray, inContext context: NSManagedObjectContext, error outError: NSErrorPointer) -> [NSObject: NSManagedObject]? {
        if let attribute = identityAttribute {
            let identifiers = attribute.valuesInJSONArray(array)
            let identityKey = attribute.name
            
            let fetchRequest = NSFetchRequest()
            fetchRequest.entity = self
            fetchRequest.returnsObjectsAsFaults = false
            fetchRequest.predicate = NSPredicate(format:"%K IN %@", identityKey, identifiers)
            
            if let fetchedObjects = context.executeFetchRequest(fetchRequest, error: outError) as? [NSManagedObject] {
                var objects: [NSObject: NSManagedObject] = [:]
                
                for object in fetchedObjects {
                    if let identifier: NSObject = object.valueForKey(identityKey) as? NSObject {
                        objects[identifier] = object
                    }
                }
                
                return objects
            }
        } else if outError != nil {
            let description = NSLocalizedString("Identity attribute not found.", comment: "Groot")
            outError.memory = NSError(code: .IdentityNotFound, localizedDescription: description)
        }
        
        return nil
    }
	
	/// Returns a JSON dictionary for a instance of this entity with the identity attribute key as key and the given value as value
	internal func dictionaryWithIdentityAttributeValue(value: AnyObject) -> JSONObject {
		
		let identityAttributeKey = self.identityAttribute?.JSONKeyPath
		
		if let identityAttributeKey = identityAttributeKey {
			return [identityAttributeKey: value]
		}
		
		assert(false, "An identity attribute related was set with the entity \(name) but it doesn't define an identityAttribute");
		
	}
    
    /// Creates a managed object for this entity by importing the given JSON object.
    public func importJSONObject(object: JSONObject, inContext context: NSManagedObjectContext, mergeChanges: Bool, error outError: NSErrorPointer) -> AnyObject? {
        let managedObjects = importJSONArray([object], inContext: context, mergeChanges: mergeChanges, error: outError)
        return managedObjects?.first
    }
    
    /// Creates an array of managed objects for this entity by importing the given JSON array.
    public func importJSONArray(array: JSONArray, inContext context: NSManagedObjectContext, mergeChanges: Bool, error outError: NSErrorPointer) -> [AnyObject]? {
        var managedObjects: [AnyObject] = []
        
        if array.count == 0 {
            // Return early and avoid further processing
            return managedObjects
        }
        
        var error: NSError? = nil
        
        context.performBlockAndWait {
            var existingObjects: [NSObject: NSManagedObject]? = nil
            
            if mergeChanges {
                existingObjects = self.existingObjectsWithJSONArray(array, inContext: context, error: &error)
                if error != nil {
                    return // exit the closure
                }
            }
            
            for o in array {
                if let object = o as? JSONObject {
                    var managedObject: NSManagedObject? = nil
                    
                    if mergeChanges {
                        if let identifier = self.identifierInJSONObject(object) as? NSObject {
                            managedObject = existingObjects?[identifier]
                        }
                    }
                    
                    if managedObject == nil {
                        managedObject = NSEntityDescription.insertNewObjectForEntityForName(self.name!, inManagedObjectContext: context) as? NSManagedObject
                    }
                    
                    if let managedObject = managedObject,
                        propertiesByName = self.propertiesByName as? [String: NSPropertyDescription]
                    {
                        for (name, property) in propertiesByName {
                            if !property.JSONSerializable {
                                continue
                            }
                            
                            switch property {
                            case let attribute as NSAttributeDescription:
                                managedObject.setAttribute(attribute, fromJSONObject: object, mergeChanges: mergeChanges, error: &error)
                            case let relationship as NSRelationshipDescription:
                                managedObject.setRelationship(relationship, fromJSONObject: object, mergeChanges: mergeChanges, error: &error)
                            default:
                                break
                            }
                            
                            if (error != nil) {
                                break
                            }
                        }
                        
                        if error == nil {
                            managedObjects.append(managedObject)
                        } else {
                            context.deleteObject(managedObject)
                            return // exit the closure
                        }
                    }
                }
            }
        }
        
        if error == nil {
            return managedObjects
        } else if outError != nil {
            outError.memory = error
        }
        
        return nil
    }
}
