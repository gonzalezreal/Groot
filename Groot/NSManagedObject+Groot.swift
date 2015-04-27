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
    internal class func entityInManagedObjectContext(context: NSManagedObjectContext) -> NSEntityDescription {
        let className = NSStringFromClass(self)
        let model = context.persistentStoreCoordinator!.managedObjectModel
        let entities = model.entities as! [NSEntityDescription]
        
        for entity in entities {
            if entity.managedObjectClassName == className {
                return entity
            }
        }
        
        assert(false, "Could not locate the entity for \(className).")
        return NSEntityDescription()
    }
    
    /// Sets an attribute on the receiver from a given JSON object.
    internal func setAttribute(attribute: NSAttributeDescription, fromJSONObject object: JSONObject, mergeChanges: Bool, error outError: NSErrorPointer) {
        
        var value: AnyObject? = nil
        
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
            // Just validate the current value
            value = valueForKey(attribute.name)
            validateValue(&value, forKey: attribute.name, error: outError)
            
            return
        }
        
        if validateValue(&value, forKey: attribute.name, error: outError) {
            setValue(value, forKey: attribute.name)
        }
    }
    
    /// Sets a relationship on the receiver form a given JSON object.
    internal func setRelationship(relationship: NSRelationshipDescription, fromJSONObject object: JSONObject, mergeChanges: Bool, error outError: NSErrorPointer) {
        
        var value: AnyObject? = nil
		
        if let rawValue: AnyObject = relationship.rawValueInJSONObject(object),
            destinationEntity = relationship.destinationEntity
        {
            var error: NSError? = nil
			
			var modifiedRawValue: AnyObject = rawValue
			if relationship.isIdentityAttributeRelated {
				
				if (relationship.toMany &&
					rawValue as? JSONArray != nil) {
					
					let array = rawValue as! JSONArray
					
					var convertedArray = [] as JSONArray
					for aValue in array {
						let dictionary = destinationEntity.dictionaryWithIdentityAttributeValue(aValue)
						convertedArray.append(dictionary)
					}
					
					modifiedRawValue = convertedArray
				}
				
				else {
					modifiedRawValue = destinationEntity.dictionaryWithIdentityAttributeValue(rawValue)
				}
			}
  
            switch modifiedRawValue {
                
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
            // Just validate the current value
            value = valueForKey(relationship.name)
            validateValue(&value, forKey: relationship.name, error: outError)
            
            return
        }
        
        if validateValue(&value, forKey: relationship.name, error: outError) {
            setValue(value, forKey: relationship.name)
        }
    }
    
    /// Returns a JSON representation of the receiver
    internal func toJSONObject(inout #processingRelationships: Set<NSRelationshipDescription>) -> JSONObject {
        var dictionary = NSMutableDictionary()
        
        if let context = self.managedObjectContext,
               propertiesByName = self.entity.propertiesByName as? [String: NSPropertyDescription]
        {
            context.performBlockAndWait {
                for (name, property) in propertiesByName {
                    if !property.JSONSerializable {
                        continue
                    }
                    
                    let keyPath = property.JSONKeyPath!
                    var value: AnyObject? = self.valueForKey(name)
                    
                    if value == nil {
                        value = NSNull()
                    } else {
                        switch property {
                        case let attribute as NSAttributeDescription:
                            if let transformer = attribute.JSONTransformer {
                                if transformer.dynamicType.allowsReverseTransformation() {
                                    value = transformer.reverseTransformedValue(value)
                                }
                            }
                            
                        case let relationship as NSRelationshipDescription:
                            if let inverseRelationship = relationship.inverseRelationship {
                                if processingRelationships.contains(inverseRelationship) {
                                    // Skip if the inverse relationship is being serialized
                                    return;
                                }
                            }
                            
                            processingRelationships.insert(relationship)
							
							let identityAttributeRelated = relationship.isIdentityAttributeRelated
                            
                            if relationship.toMany {
                                var managedObjects: [NSManagedObject] = []
                                
                                switch value {
                                case let orderedSet as NSOrderedSet:
                                    managedObjects = orderedSet.array as! [NSManagedObject]
                                case let set as NSSet:
                                    managedObjects = set.allObjects as! [NSManagedObject]
                                default:
                                    break
                                }
								
								if identityAttributeRelated {
									let name = relationship.destinationEntity?.identityAttribute?.name
									if let name = name {
										value = managedObjects.map { $0.valueForKey(name)! }
									}
									else {
										assert(false, "An identity attribute related was set with the entity \(name) but it doesn't define an identityAttribute");
									}
								}
								else {
									value = managedObjects.map { $0.toJSONObject(processingRelationships: &processingRelationships) }
								}
								
                            } else {
								
								if identityAttributeRelated {
									let name = relationship.destinationEntity?.identityAttribute?.name
									if let name = name {
										value = (value as? NSManagedObject)?.valueForKey(name)
									}
									else {
										assert(false, "An identity attribute related was set with the entity \(name) but it doesn't define an identityAttribute");
									}
								}
								else {
									value = (value as? NSManagedObject)?.toJSONObject(processingRelationships: &processingRelationships)
								}
								
                            }
                            
                        default:
                            break
                        }
                    }
                    
                    var components = keyPath.componentsSeparatedByString(".")
                    components.removeLast()
                    
                    if components.count > 0 {
                        // Create a dictionary for each key path component
                        var tmpDictionary = dictionary
                        for component in components {
                            if tmpDictionary[component] == nil {
                                tmpDictionary[component] = NSMutableDictionary()
                            }
                            
                            tmpDictionary = tmpDictionary[component] as! NSMutableDictionary
                        }
                    }
                    
                    dictionary.setValue(value, forKeyPath: keyPath)
                }
            }
        }
        
        return dictionary.copy() as! JSONObject
    }
}
