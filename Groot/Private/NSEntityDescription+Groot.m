// NSEntityDescription+Groot.m
//
// Copyright (c) 2014-2015 Guillermo Gonzalez
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

#import "NSEntityDescription+Groot.h"
#import "NSPropertyDescription+Groot.h"
#import "NSAttributeDescription+Groot.h"
#import "NSManagedObject+Groot.h"

#import "GRTError.h"

NS_ASSUME_NONNULL_BEGIN

@implementation NSEntityDescription (Groot)

+ (nullable NSEntityDescription *)grt_entityForName:(NSString *)entityName
                                          inContext:(NSManagedObjectContext *)context
                                              error:(NSError *__autoreleasing  __nullable * __nullable)error
{
    NSEntityDescription *entity = [self entityForName:entityName inManagedObjectContext:context];
    
    if (entity == nil && error != nil) {
        *error = [NSError errorWithDomain:GRTErrorDomain code:GRTErrorEntityNotFound userInfo:nil];
    }
    
    return entity;
}

- (BOOL)grt_hasIdentity {
    return [self grt_identityAttribute] != nil;
}

- (nullable NSArray *)grt_importJSONArray:(NSArray *)array
                                inContext:(NSManagedObjectContext *)context
                             mergeChanges:(BOOL)mergeChanges
                                    error:(NSError *__autoreleasing  __nullable * __nullable)outError
{
    NSMutableArray * __block managedObjects = [NSMutableArray array];
    NSError * __block error = nil;
    
    if (array.count == 0) {
        // Return early and avoid further processing
        return managedObjects;
    }
    
    [context performBlockAndWait:^{
        NSDictionary *existingObjects = nil;
        
        if (mergeChanges) {
            existingObjects = [self grt_existingObjectsWithJSONArray:array inContext:context error:&error];
            if (error != nil) return; // exit the block
        }
        
        for (id obj in array) {
            if (![obj isKindOfClass:[NSDictionary class]]) continue;
            
            NSDictionary *dictionary = obj;
            NSManagedObject *managedObject = nil;
            
            if (mergeChanges) {
                id identifier = [self grt_identifierInJSONDictionary:dictionary];
                if (identifier != nil) {
                    managedObject = existingObjects[identifier];
                }
            }
            
            if (managedObject == nil) {
                managedObject = [[self class] insertNewObjectForEntityForName:self.name inManagedObjectContext:context];
            }
            
            [self.propertiesByName enumerateKeysAndObjectsUsingBlock:^(NSString *name, NSPropertyDescription *property, BOOL *stop) {
                if (![property grt_JSONSerializable]) {
                    return; // continue
                }
                
                if ([property isKindOfClass:[NSAttributeDescription class]]) {
                    NSAttributeDescription *attribute = (NSAttributeDescription *)property;
                    [managedObject grt_setAttribute:attribute fromJSONDictionary:dictionary mergeChanges:mergeChanges error:&error];
                } else if ([property isKindOfClass:[NSPropertyDescription class]]) {
                    NSRelationshipDescription *relationship = (NSRelationshipDescription *)property;
                    [managedObject grt_setRelationship:relationship fromJSONDictionary:dictionary mergeChanges:mergeChanges error:&error];
                }
                
                *stop = (error != nil); // break on error
            }];
            
            if (error != nil) {
                [context deleteObject:managedObject];
                return; // exit the block
            }
            
            [managedObjects addObject:managedObject];
        }
    }];
    
    if (error != nil) {
        if (outError) *outError = error;
        return nil;
    }
    
    return managedObjects;
}

#pragma mark - Private

- (nullable NSAttributeDescription *)grt_identityAttribute {
    NSString *attributeName = nil;
    NSEntityDescription *entity = self;
    
    while (entity != nil && attributeName == nil) {
        attributeName = entity.userInfo[@"identityAttribute"];
        entity = [entity superentity];
    }
    
    if (attributeName != nil) {
        return self.attributesByName[attributeName];
    }
    
    return nil;
}

- (nullable id)grt_identifierInJSONDictionary:(NSDictionary *)dictionary {
    NSAttributeDescription *identityAttribute = [self grt_identityAttribute];
    if (identityAttribute != nil) {
        return [identityAttribute grt_valueForJSONValue:dictionary];
    }
    
    return nil;
}

- (nullable NSDictionary *)grt_existingObjectsWithJSONArray:(NSArray *)array
                                                  inContext:(NSManagedObjectContext *)context
                                                      error:(NSError *__autoreleasing  __nullable * __nullable)outError
{
    NSAttributeDescription *attribute = [self grt_identityAttribute];
    
    if (attribute == nil) {
        if (outError) {
            NSString *format = NSLocalizedString(@"%@ has no identity attribute", @"Groot");
            NSString *message = [NSString stringWithFormat:format, self.name];
            *outError = [NSError errorWithDomain:GRTErrorDomain
                                            code:GRTErrorIdentityNotFound
                                        userInfo:@{ NSLocalizedDescriptionKey: message }];
        }
        
        return nil;
    }
    
    NSArray *identifiers = [attribute grt_valuesInJSONArray:array];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    fetchRequest.entity = self;
    fetchRequest.returnsObjectsAsFaults = NO;
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"%K IN %@", attribute.name, identifiers];
    
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:outError];
    
    if (fetchedObjects != nil) {
        NSMutableDictionary *objects = [NSMutableDictionary dictionaryWithCapacity:fetchedObjects.count];
        
        for (NSManagedObject *object in fetchedObjects) {
            id identifier = [object valueForKey:attribute.name];
            if (identifier != nil) {
                objects[identifier] = object;
            }
        }
        return objects;
    }
    
    return nil;
}

@end

NS_ASSUME_NONNULL_END
