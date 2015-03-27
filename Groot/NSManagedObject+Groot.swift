//
//  NSManagedObject+Groot.swift
//  Groot
//
//  Created by Guille Gonzalez on 29/03/15.
//  Copyright (c) 2015 Guille Gonzalez. All rights reserved.
//

import CoreData

extension NSManagedObject {
    /// Returns the entity for this managed object in a given context.
    internal class func entityInManagedObjectContext(context: NSManagedObjectContext, error outError: NSErrorPointer) -> NSEntityDescription? {
        let className = NSStringFromClass(self)
        
        if let model = context.persistentStoreCoordinator?.managedObjectModel {
            let entities = model.entities as! [NSEntityDescription]
            
            for entity in entities {
                if entity.managedObjectClassName == className {
                    return entity
                }
            }
        }
        
        if outError != nil {
            let description = String(format: NSLocalizedString("Could not find the entity for %@.", comment: "Groot"), className)
            outError.memory = NSError(code: .EntityNotFound, localizedDescription: description)
        }
        
        return nil
    }
    
    /// Sets an attribute on the receiver from a given JSON object.
    internal func setAttribute(attribute: NSAttributeDescription, fromJSONObject object: JSONObject, mergeChanges: Bool, error outError: NSErrorPointer) {
        
        var value: AnyObject? = nil
        var shouldSetValue = true
        
        if let rawValue: AnyObject = attribute.rawValueInJSONObject(object) {
            switch rawValue {
            case is NSNull:
                break
            default:
                if let transformer = attribute.JSONTransformer {
                    value = transformer.transformedValue(rawValue)
                } else {
                    value = rawValue
                }
            }
        }
        else if mergeChanges {
            shouldSetValue = false
        }
        
        if shouldSetValue {
            if validateValue(&value, forKey: attribute.name, error: outError) {
                setValue(value, forKey: attribute.name)
            }
        }
    }
    
    /// Sets a relationship on the receiver form a given JSON object.
    internal func setRelationship(relationship: NSRelationshipDescription, fromJSONObject object: JSONObject, mergeChanges: Bool, error outError: NSErrorPointer) {
        
        var value: AnyObject? = nil
        var shouldSetValue = true
        
        if let rawValue: AnyObject = relationship.rawValueInJSONObject(object),
            destinationEntity = relationship.destinationEntity
        {
            var error: NSError? = nil
            
            switch rawValue {
                
            case let object as JSONObject where !relationship.toMany:
                if let managedObject: AnyObject = destinationEntity.importJSONObject(object, inContext: managedObjectContext!, mergeChanges: mergeChanges, error: &error) {
                    value = managedObject
                }
                
            case let array as JSONArray where relationship.toMany:
                if let managedObjects = destinationEntity.importJSONArray(array, inContext: managedObjectContext!, mergeChanges: mergeChanges, error: &error) {
                    value = relationship.ordered ? NSOrderedSet(array: managedObjects) : NSSet(array: managedObjects)
                }
                
            case is NSNull:
                break
                
            default:
                let description = String(format: NSLocalizedString("Cannot serialize '%@' into relationship '%@.%@'.", comment: "Groot"), relationship.JSONKeyPath!, relationship.entity.name!, relationship.name)
                error = NSError(code: .InvalidJSONObject, localizedDescription: description)
            }
            
            if error != nil {
                if outError != nil {
                    outError.memory = error
                }
                
                return
            }
        }
        else if mergeChanges {
            shouldSetValue = false
        }
        
        if shouldSetValue {
            if validateValue(&value, forKey: relationship.name, error: outError) {
                setValue(value, forKey: relationship.name)
            }
        }
    }
}
