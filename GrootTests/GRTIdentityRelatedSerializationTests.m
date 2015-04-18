//
//  GRTIdentityRelatedSerializationTests.m
//  Groot
//
//  Created by Manu on 16/4/15.
//  Copyright (c) 2015 Guillermo Gonzalez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import <XCTest/XCTest.h>
#import <Groot/Groot.h>

@interface GRTIdentityRelatedSerializationTests : XCTestCase

@property (strong, nonatomic) GRTManagedStore *store;
@property (strong, nonatomic) NSManagedObjectContext *context;

@end

@implementation GRTIdentityRelatedSerializationTests

- (void)setUp {
    [super setUp];
    
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSURL *modelURL = [bundle URLForResource:@"IdentityRelatedModel" withExtension:@"momd"];
    NSManagedObjectModel *model = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    
    self.store = [GRTManagedStore managedStoreWithModel:model];
    self.context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    self.context.persistentStoreCoordinator = self.store.persistentStoreCoordinator;
    
}

- (void)tearDown {
    self.store = nil;
    [super tearDown];
}

- (void) testMergeObjectsWithToOneRelationshipIdentityAttributeRelated {
    NSDictionary *batmanJSON = @{
                                 @"id": @"1",
                                 @"name": @"Batman",
                                 @"publisher": @"1"
                                 };
    
    NSManagedObject *batman = [GRTJSONSerialization mergeObjectForEntityName:@"Character"
                                                          fromJSONDictionary:batmanJSON
                                                      inManagedObjectContext:self.context
                                                                       error:nil];
    
    NSArray *publishersJSONArray = @[
                                     @{
                                         @"id" : @"1",
                                         @"name": @"Marvel"
                                         },
                                     
                                     @{
                                         @"id" : @"2",
                                         @"name": @"DC"
                                         }
                                     ];
    
    [GRTJSONSerialization mergeObjectsForEntityName:@"Publisher"
                                      fromJSONArray:publishersJSONArray
                             inManagedObjectContext:self.context
                                              error:nil];
    
    XCTAssertEqualObjects([batman valueForKeyPath:@"publisher.name"], @"Marvel", @"should serialize relationship");
}

- (void) testMergeObjectsWithToManyRelationshipIdentityAttributeRelated {
    NSDictionary *marvelJSON = @{
                                 @"id" : @"1",
                                 @"name": @"Marvel",
                                 @"characters": @[@"1", @"2", @"4"],
                                 };
    
    NSManagedObject *marvel = [GRTJSONSerialization mergeObjectForEntityName:@"Publisher"
                                                          fromJSONDictionary:marvelJSON
                                                      inManagedObjectContext:self.context
                                                                       error:nil];
    
    NSArray *charactersJSONArray = @[
                                     @{
                                         @"id": @"1",
                                         @"name": @"Batman",
                                         },
                                     @{
                                         @"id": @"2",
                                         @"name": @"Superman",
                                         },
                                     @{
                                         @"id": @"3",
                                         @"name": @"Spiderman",
                                         },
                                     @{
                                         @"id": @"4",
                                         @"name": @"Hulk",
                                         }
                                     ];
    
    [GRTJSONSerialization mergeObjectsForEntityName:@"Character"
                                      fromJSONArray:charactersJSONArray
                             inManagedObjectContext:self.context
                                              error:nil];
    
    NSSet *marvelCharacters = [marvel valueForKey:@"characters"];
    NSSet *names = [marvelCharacters valueForKey:@"name"];
    NSSet *expectedSet = [NSSet setWithArray:@[@"Batman", @"Superman", @"Hulk"]];
    
    XCTAssertEqualObjects(names, expectedSet, @"should serialize relationship");
}

- (void)testJSONDictionaryFromManagedObjectWithToOneRelationshipIdentityAttributeRelated {
    
    NSManagedObject *marvel = [NSEntityDescription insertNewObjectForEntityForName:@"Publisher"
                                                            inManagedObjectContext:self.context];
    [marvel setValue:@"1" forKey:@"identifier"];
    [marvel setValue:@"Marvel" forKey:@"name"];
    
    NSManagedObject *batman = [NSEntityDescription insertNewObjectForEntityForName:@"Character"
                                                            inManagedObjectContext:self.context];
    [batman setValue:@"1" forKey:@"identifier"];
    [batman setValue:@"Batman" forKey:@"name"];
    [batman setValue:marvel forKey:@"publisher"];
    
    NSDictionary *batmanJSON = [GRTJSONSerialization JSONDictionaryFromManagedObject:batman];
    
    NSDictionary *expectedDictionary = @{
                                         @"id": @"1",
                                         @"name": @"Batman",
                                         @"publisher": @"1"
                                         };
    
    XCTAssertEqualObjects(batmanJSON, expectedDictionary, @"should serialize relationship");
    
}

- (void)testJSONDictionaryFromManagedObjectWithToManyRelationshipIdentityAttributeRelated {
    
    NSManagedObject *marvel = [NSEntityDescription insertNewObjectForEntityForName:@"Publisher"
                                                            inManagedObjectContext:self.context];
    [marvel setValue:@"1" forKey:@"identifier"];
    [marvel setValue:@"Marvel" forKey:@"name"];
    
    NSManagedObject *batman = [NSEntityDescription insertNewObjectForEntityForName:@"Character"
                                                            inManagedObjectContext:self.context];
    [batman setValue:@"1" forKey:@"identifier"];
    [batman setValue:@"Batman" forKey:@"name"];
    [batman setValue:marvel forKey:@"publisher"];
    
    NSManagedObject *superman = [NSEntityDescription insertNewObjectForEntityForName:@"Character"
                                                            inManagedObjectContext:self.context];
    [superman setValue:@"2" forKey:@"identifier"];
    [superman setValue:@"Superman" forKey:@"name"];
    [superman setValue:marvel forKey:@"publisher"];
    
    NSDictionary *marvelJSON = [GRTJSONSerialization JSONDictionaryFromManagedObject:marvel];
    NSSet *characterIds = [NSSet setWithArray:[marvelJSON valueForKey:@"characters"]];
    NSSet *expectedSet = [NSSet setWithArray:@[@"1", @"2"]];
    
    XCTAssertEqualObjects(characterIds, expectedSet, @"should serialize relationship");
    
}
@end
