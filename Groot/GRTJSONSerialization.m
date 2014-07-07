// GRTJSONSerializer.m
//
// Copyright (c) 2014 Guillermo Gonzalez
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

#import "GRTJSONSerialization.h"

#import "NSPropertyDescription+Groot.h"
#import "NSAttributeDescription+Groot.h"

NSString * const GRTJSONSerializationErrorDomain = @"GRTJSONSerializationErrorDomain";
const NSInteger GRTJSONSerializationErrorInvalidRelationshipClass = 2;

@implementation GRTJSONSerialization

+ (id)insertObjectForEntityName:(NSString *)entityName
             fromJSONDictionary:(NSDictionary *)JSONDictionary
         inManagedObjectContext:(NSManagedObjectContext *)context
                          error:(NSError *__autoreleasing *)error
{
    NSParameterAssert(entityName);
    NSParameterAssert(JSONDictionary);
    NSParameterAssert(context);
    
    NSError * __block tmpError = nil;
    NSManagedObject * __block managedObject = nil;
    
    [context performBlockAndWait:^{
        managedObject = [NSEntityDescription insertNewObjectForEntityForName:entityName
                                                      inManagedObjectContext:context];
        NSDictionary *propertiesByName = managedObject.entity.propertiesByName;
        
        [propertiesByName enumerateKeysAndObjectsUsingBlock:^(NSString *name, NSPropertyDescription *property, BOOL *stop) {
            if ([property isKindOfClass:[NSAttributeDescription class]]) {
                *stop = ![self serializeAttribute:(NSAttributeDescription *)property
                               fromJSONDictionary:JSONDictionary
                                  inManagedObject:managedObject
                                            merge:NO
                                            error:&tmpError];
            } else if ([property isKindOfClass:[NSRelationshipDescription class]]) {
                *stop = ![self serializeRelationship:(NSRelationshipDescription *)property
                                  fromJSONDictionary:JSONDictionary
                                     inManagedObject:managedObject
                                               merge:NO
                                               error:&tmpError];
            }
        }];
        
        if (tmpError != nil) {
            [context deleteObject:managedObject];
            managedObject = nil;
        }
    }];
    
    if (error != nil) {
        *error = tmpError;
    }
    
    return managedObject;
}

+ (NSArray *)insertObjectsForEntityName:(NSString *)entityName
                          fromJSONArray:(NSArray *)JSONArray
                 inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
                                  error:(NSError *__autoreleasing *)error
{
    // TODO: implement
    return nil;
}

+ (id)mergeObjectForEntityName:(NSString *)entityName
            fromJSONDictionary:(NSDictionary *)JSONDictionary
        inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
                         error:(NSError *__autoreleasing *)error
{
    // TODO: implement
    return nil;
}

+ (NSArray *)mergeObjectsForEntityName:(NSString *)entityName
                         fromJSONArray:(NSArray *)JSONArray
                inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
                                 error:(NSError *__autoreleasing *)error
{
    // TODO: implement
    return nil;
}

#pragma mark - Private

+ (BOOL)serializeAttribute:(NSAttributeDescription *)attribute
        fromJSONDictionary:(NSDictionary *)JSONDictionary
           inManagedObject:(NSManagedObject *)managedObject
                     merge:(BOOL)merge
                     error:(NSError *__autoreleasing *)error
{
    id value = [self valueForKeyPath:[attribute grt_JSONKeyPath]];

    if (merge && value == nil) {
        return YES;
    }

    if ([value isEqual:NSNull.null]) {
        value = nil;
    }
    
    if (value != nil) {
        NSValueTransformer *transformer = [attribute grt_JSONTransformer];
        if (transformer) {
            value = [transformer transformedValue:value];
        }
    }
    
    if ([managedObject validateValue:&value forKey:attribute.name error:error]) {
        [managedObject setValue:value forKey:attribute.name];
        return YES;
    }
    
    return NO;
}

+ (BOOL)serializeRelationship:(NSRelationshipDescription *)relationship
           fromJSONDictionary:(NSDictionary *)JSONDictionary
              inManagedObject:(NSManagedObject *)managedObject
                        merge:(BOOL)merge
                        error:(NSError *__autoreleasing *)error
{
    id value = [self valueForKeyPath:[relationship grt_JSONKeyPath]];
    
    if (merge && value == nil) {
        return YES;
    }
    
    if ([value isEqual:NSNull.null]) {
        value = nil;
    }
    
    if (value != nil) {
        NSString *entityName = relationship.entity.name;
        NSManagedObjectContext *context = managedObject.managedObjectContext;
        NSError *tmpError = nil;
        
        if ([relationship isToMany]) {
            if (![value isKindOfClass:[NSArray class]]) {
                if (error) {
                    NSString *message = [NSString stringWithFormat:NSLocalizedString(@"Value with key path %@ cannot be serialized into a to-many relationship", @""), [relationship grt_JSONKeyPath]];
                    NSDictionary *userInfo = @{
                        NSLocalizedDescriptionKey: message
                    };
                    
                    *error = [NSError errorWithDomain:GRTJSONSerializationErrorDomain
                                                 code:GRTJSONSerializationErrorInvalidRelationshipClass
                                             userInfo:userInfo];
                }
                
                return NO;
            }
            
            if (merge) {
                value = [self mergeObjectsForEntityName:entityName
                                          fromJSONArray:value
                                 inManagedObjectContext:context
                                                  error:&tmpError];
            } else {
                value = [self insertObjectsForEntityName:entityName
                                           fromJSONArray:value
                                  inManagedObjectContext:context
                                                   error:&tmpError];
            }
        } else {
            if (![value isKindOfClass:[NSDictionary class]]) {
                if (error) {
                    NSString *message = [NSString stringWithFormat:NSLocalizedString(@"Value with key path %@ cannot be serialized into a to-one relationship", @""), [relationship grt_JSONKeyPath]];
                    NSDictionary *userInfo = @{
                        NSLocalizedDescriptionKey: message
                    };
                    
                    *error = [NSError errorWithDomain:GRTJSONSerializationErrorDomain
                                                 code:GRTJSONSerializationErrorInvalidRelationshipClass
                                             userInfo:userInfo];
                }
                
                return NO;
            }
            
            if (merge) {
                value = [self mergeObjectForEntityName:entityName
                                    fromJSONDictionary:value
                                inManagedObjectContext:context
                                                 error:&tmpError];
            } else {
                value = [self insertObjectForEntityName:entityName
                                     fromJSONDictionary:value
                                 inManagedObjectContext:context
                                                  error:&tmpError];
            }
        }
        
        if (tmpError != nil) {
            if (error) {
                *error = tmpError;
            }
            return NO;
        }
    }
    
    if ([managedObject validateValue:&value forKey:relationship.name error:error]) {
        [managedObject setValue:value forKey:relationship.name];
        return YES;
    }
    
    return NO;
}

@end
