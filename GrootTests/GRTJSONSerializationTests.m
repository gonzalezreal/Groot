//
//  GRTJSONSerializationTests.m
//  Groot
//
//  Created by guille on 03/07/14.
//  Copyright (c) 2014 Guillermo Gonzalez. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <Groot/Groot.h>

#import "GRTModels.h"
#import "NSEntityDescription+Groot.h"

@interface GRTJSONSerializationTests : XCTestCase

@property (strong, nonatomic) GRTManagedStore *store;
@property (strong, nonatomic) NSManagedObjectContext *context;

@end

@implementation GRTJSONSerializationTests

- (void)setUp {
    [super setUp];
    
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSManagedObjectModel *model = [NSManagedObjectModel mergedModelFromBundles:@[bundle]];
    
    self.store = [[GRTManagedStore alloc] initWithModel:model error:nil];
    self.context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    self.context.persistentStoreCoordinator = self.store.persistentStoreCoordinator;
    
    [NSValueTransformer grt_setValueTransformerWithName:@"GRTTestTransformer" transformBlock:^id(NSString *value) {
        if (value) {
            return @([value integerValue]);
        }
        
        return nil;
    } reverseTransformBlock:^id(NSNumber *value) {
        return [value stringValue];
    }];
}

- (void)tearDown {
    self.store = nil;
    [NSValueTransformer setValueTransformer:nil forName:@"GRTTestTransformer"];
    
    [super tearDown];
}

- (void)testInsertObject {
    NSDictionary *batmanJSON = @{
        @"name": @"Batman",
        @"real_name": @"Bruce Wayne",
        @"id": @"1699",
        @"powers": @[
            @{
                @"id": @"4",
                @"name": @"Agility"
            },
            NSNull.null,
            @{
                @"id": @"9",
                @"name": @"Insanely Rich"
            }
        ],
        @"publisher": @{
            @"id": @"10",
            @"name": @"DC Comics"
        }
    };
    
    NSError *error = nil;
    GRTCharacter *batman = [GRTJSONSerialization insertObjectForEntityName:@"Character" fromJSONDictionary:batmanJSON inManagedObjectContext:self.context error:&error];
    XCTAssertNil(error, @"shouldn't return an error");
    
    XCTAssertEqualObjects(@"Character", batman.entity.name, @"should serialize to the right entity");
    
    XCTAssertEqualObjects(@"Batman", batman.name, @"should serialize attributes");
    XCTAssertEqualObjects(@1699, batman.identifier, @"should serialize attributes");
    XCTAssertEqualObjects(@"Bruce Wayne", batman.realName, @"should serialize attributes");
    
    GRTPower *power = batman.powers[0];
    
    XCTAssertEqualObjects(@"Power", power.entity.name, @"should serialize to-many relationships");
    XCTAssertEqualObjects(@4, power.identifier, @"should serialize to-many relationships");
    XCTAssertEqualObjects(@"Agility", power.name, @"should serialize to-many relationships");
    
    power = batman.powers[1];
    
    XCTAssertEqualObjects(@9, power.identifier, @"should serialize to-many relationships");
    XCTAssertEqualObjects(@"Insanely Rich", power.name, @"should serialize to-many relationships");
    
    XCTAssertEqualObjects(@"Publisher", batman.publisher.entity.name, @"should serialize to-one relationships");
    XCTAssertEqualObjects(@10, batman.publisher.identifier, @"should serialize to-one relationships");
    XCTAssertEqualObjects(@"DC Comics", batman.publisher.name, @"should serialize to-one relationships");
}

- (void)testInsertInvalidJSON {
    NSArray *invalidJSON = @[@1];
    
    NSError *error = nil;
    [GRTJSONSerialization insertObjectsForEntityName:@"Character" fromJSONArray:invalidJSON inManagedObjectContext:self.context error:&error];
    
    XCTAssertNotNil(error, @"should return an error");
    XCTAssertEqualObjects(GRTJSONSerializationErrorDomain, error.domain, @"should return a serialization error");
    XCTAssertEqual(GRTJSONSerializationErrorInvalidJSONObject, error.code, @"should return an invalid JSON error");
}

- (void)testInsertInvalidToManyRelationship {
    NSDictionary *invalidBatman = @{
        @"id": @"1699",
        @"name": @"Batman",
        @"real_name": @"Bruce Wayne",
        @"powers": @{                   // This should be a JSON array
            @"id": @"4",
            @"name": @"Agility"
        }
    };
    
    NSError *error = nil;
    [GRTJSONSerialization insertObjectForEntityName:@"Character" fromJSONDictionary:invalidBatman inManagedObjectContext:self.context error:&error];
    
    XCTAssertNotNil(error, @"should return an error");
    XCTAssertEqualObjects(GRTJSONSerializationErrorDomain, error.domain, @"should return a serialization error");
    XCTAssertEqual(GRTJSONSerializationErrorInvalidJSONObject, error.code, @"should return an invalid JSON error");
}

- (void)testInsertInvalidToOneRelationship {
    NSDictionary *invalidBatman = @{
        @"id": @"1699",
        @"name": @"Batman",
        @"real_name": @"Bruce Wayne",
        @"publisher": @"DC"             // This should be a JSON dictionary
    };
    
    NSError *error = nil;
    [GRTJSONSerialization insertObjectForEntityName:@"Character" fromJSONDictionary:invalidBatman inManagedObjectContext:self.context error:&error];
    
    XCTAssertNotNil(error, @"should return an error");
    XCTAssertEqualObjects(GRTJSONSerializationErrorDomain, error.domain, @"should return a serialization error");
    XCTAssertEqual(GRTJSONSerializationErrorInvalidJSONObject, error.code, @"should return an invalid JSON error");
}

- (void)testMergeObject {
    NSDictionary *batmanJSON = @{
        @"id": @"1699",
        @"name": @"Batman",
        @"real_name": @"Bruce Wayne",
        @"powers": @[
            @{
                @"id": @"4",
                @"name": @"Agility"
            },
            NSNull.null,
            @{
                @"id": @"9",
                @"name": @"Insanely Rich"
            }
        ],
        @"publisher": @{
            @"id": @"10",
            @"name": @"DC"
        }
    };
    
    NSError *error = nil;
    [GRTJSONSerialization mergeObjectForEntityName:@"Character" fromJSONDictionary:batmanJSON inManagedObjectContext:self.context error:&error];
    XCTAssertNil(error, @"shouldn't return an error");
    
    NSArray *updateJSON = @[
        @{
            @"id": @"1699",
            @"real_name": NSNull.null,  // Should reset Batman real name
            @"publisher" : @{
                @"id": @"10",
                @"name": @"DC Comics"   // Should update the publisher name
            }
        },
        @{
            @"id": @"1455",
            @"name": @"Iron Man",
            @"real_name": @"Tony Stark",
            @"powers": @[
                @{
                    @"id": @"31",
                    @"name": @"Power Suit"
                },
                @{
                    @"id": @"9",
                    @"name": @"Filthy Rich" // Should update the 'Rich' power name
                }
            ],
        }
    ];
    
    [GRTJSONSerialization mergeObjectsForEntityName:@"Character" fromJSONArray:updateJSON inManagedObjectContext:self.context error:&error];
    XCTAssertNil(error, @"shouldn't return an error");
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"identifier" ascending:YES];
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Character"];
    fetchRequest.sortDescriptors = @[sortDescriptor];
    
    NSArray *characters = [self.context executeFetchRequest:fetchRequest error:NULL];
    
    XCTAssertEqual(2U, characters.count, @"there should be 2 characters");
    
    GRTCharacter *ironMan = characters[0];
    
    XCTAssertEqualObjects(@"Character", ironMan.entity.name, @"should serialize to the right entity");
    XCTAssertEqualObjects(@"Iron Man", ironMan.name, @"should serialize attributes");
    XCTAssertEqualObjects(@1455, ironMan.identifier, @"should serialize attributes");
    XCTAssertEqualObjects(@"Tony Stark", ironMan.realName, @"should serialize attributes");
    
    GRTPower *powerSuit = ironMan.powers[0];
    
    XCTAssertEqualObjects(@"Power", powerSuit.entity.name, @"should serialize to-many relationships");
    XCTAssertEqualObjects(@31, powerSuit.identifier, @"should serialize to-many relationships");
    XCTAssertEqualObjects(@"Power Suit", powerSuit.name, @"should serialize to-many relationships");
    
    GRTPower *ironManRich = ironMan.powers[1];
    
    XCTAssertEqualObjects(@9, ironManRich.identifier, @"should serialize to-many relationships");
    XCTAssertEqualObjects(@"Filthy Rich", ironManRich.name, @"should serialize to-many relationships");
    
    GRTCharacter *batman = characters[1];
    
    XCTAssertEqualObjects(@"Character", batman.entity.name, @"should serialize to the right entity");
    XCTAssertEqualObjects(@"Batman", batman.name, @"should serialize attributes");
    XCTAssertEqualObjects(@1699, batman.identifier, @"should serialize attributes");
    XCTAssertNil(batman.realName, @"should update explicit null values");
    
    GRTPower *agility = batman.powers[0];
    
    XCTAssertEqualObjects(@"Power", agility.entity.name, @"should serialize to-many relationships");
    XCTAssertEqualObjects(@4, agility.identifier, @"should serialize to-many relationships");
    XCTAssertEqualObjects(@"Agility", agility.name, @"should serialize to-many relationships");
    
    GRTPower *batmanRich = batman.powers[1];
    
    XCTAssertEqualObjects(@9, batmanRich.identifier, @"should serialize to-many relationships");
    XCTAssertEqualObjects(@"Filthy Rich", batmanRich.name, @"should serialize to-many relationships");
    
    XCTAssertEqualObjects(batmanRich, ironManRich, @"should merge relationships properly");
    
    XCTAssertEqualObjects(@"Publisher", batman.publisher.entity.name, @"should serialize to-one relationships");
    XCTAssertEqualObjects(@10, batman.publisher.identifier, @"should serialize to-one relationships");
    XCTAssertEqualObjects(@"DC Comics", batman.publisher.name, @"should serialize to-one relationships");
    
    fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Power"];
    NSUInteger powerCount = [self.context countForFetchRequest:fetchRequest error:NULL];
    XCTAssertEqual(3U, powerCount, @"there should be 3 power objects");
    
    fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Publisher"];
    NSUInteger publisherCount = [self.context countForFetchRequest:fetchRequest error:NULL];
    XCTAssertEqual(1U, publisherCount, @"there should be 1 publisher objects");
}

- (void)testMergeInvalidJSON {
    NSArray *invalidJSON = @[@1];
    
    NSError *error = nil;
    [GRTJSONSerialization mergeObjectsForEntityName:@"Character" fromJSONArray:invalidJSON inManagedObjectContext:self.context error:&error];
    
    XCTAssertNotNil(error, @"should return an error");
    XCTAssertEqualObjects(GRTJSONSerializationErrorDomain, error.domain, @"should return a serialization error");
    XCTAssertEqual(GRTJSONSerializationErrorInvalidJSONObject, error.code, @"should return an invalid JSON error");
}

- (void)testMergeInvalidToManyRelationship {
    NSDictionary *invalidBatman = @{
        @"id": @"1699",
        @"name": @"Batman",
        @"real_name": @"Bruce Wayne",
        @"powers": @{                   // This should be a JSON array
            @"id": @"4",
            @"name": @"Agility"
        }
    };
    
    NSError *error = nil;
    [GRTJSONSerialization mergeObjectForEntityName:@"Character" fromJSONDictionary:invalidBatman inManagedObjectContext:self.context error:&error];
    
    XCTAssertNotNil(error, @"should return an error");
    XCTAssertEqualObjects(GRTJSONSerializationErrorDomain, error.domain, @"should return a serialization error");
    XCTAssertEqual(GRTJSONSerializationErrorInvalidJSONObject, error.code, @"should return an invalid JSON error");
}

- (void)testMergeInvalidToOneRelationship {
    NSDictionary *invalidBatman = @{
        @"id": @"1699",
        @"name": @"Batman",
        @"real_name": @"Bruce Wayne",
        @"publisher": @"DC"             // This should be a JSON dictionary
    };
    
    NSError *error = nil;
    [GRTJSONSerialization mergeObjectForEntityName:@"Character" fromJSONDictionary:invalidBatman inManagedObjectContext:self.context error:&error];
    
    XCTAssertNotNil(error, @"should return an error");
    XCTAssertEqualObjects(GRTJSONSerializationErrorDomain, error.domain, @"should return a serialization error");
    XCTAssertEqual(GRTJSONSerializationErrorInvalidJSONObject, error.code, @"should return an invalid JSON error");
}

- (void)testMergeWithoutIdentityAttribute {
    NSEntityDescription *powerEntity = self.store.managedObjectModel.entitiesByName[@"Power"];
    powerEntity.userInfo = @{}; // Remove the identity attribute name from the entity
    
    NSDictionary *batman = @{
        @"id": @"1699",
        @"name": @"Batman",
        @"real_name": @"Bruce Wayne",
        @"powers": @[
            @{
                @"id": @"4",
                @"name": @"Agility"
            }
        ]
    };
    
    XCTAssertThrows([GRTJSONSerialization mergeObjectForEntityName:@"Character" fromJSONDictionary:batman inManagedObjectContext:self.context error:NULL], @"merge should assert when the identity attribute is not specified");
}

- (void)testMergeWithNoIdentityAttributeJSONKeyPath {
    NSEntityDescription *powerEntity = self.store.managedObjectModel.entitiesByName[@"Power"];
    NSAttributeDescription *identityAttribute = [powerEntity grt_identityAttribute];
    identityAttribute.userInfo = @{
        @"JSONKeyPath": @"null"
    };
    
    NSDictionary *batman = @{
        @"id": @"1699",
        @"name": @"Batman",
        @"real_name": @"Bruce Wayne",
        @"powers": @[
            @{
                @"id": @"4",
                @"name": @"Agility"
            }
        ]
    };
    
    XCTAssertThrows([GRTJSONSerialization mergeObjectForEntityName:@"Character" fromJSONDictionary:batman inManagedObjectContext:self.context error:NULL], @"merge should assert when the identity attribute doesn't have a JSON key path");
}

- (void)testJSONDictionaryFromManagedObject {
    GRTPublisher *dc = [NSEntityDescription insertNewObjectForEntityForName:@"Publisher" inManagedObjectContext:self.context];
    dc.identifier = @10;
    dc.name = @"DC Comics";
    
    GRTPower *agility = [NSEntityDescription insertNewObjectForEntityForName:@"Power" inManagedObjectContext:self.context];
    agility.identifier = @4;
    agility.name = @"Agility";
    
    GRTPower *wealth = [NSEntityDescription insertNewObjectForEntityForName:@"Power" inManagedObjectContext:self.context];
    wealth.identifier = @9;
    wealth.name = @"Insanely Rich";
    
    GRTCharacter *batman = [NSEntityDescription insertNewObjectForEntityForName:@"Character" inManagedObjectContext:self.context];
    batman.identifier = @1699;
    batman.name = @"Batman";
    batman.realName = @"Bruce Wayne";
    batman.powers = [[NSOrderedSet alloc] initWithArray:@[agility, wealth]];
    batman.publisher = dc;
    
    NSDictionary *JSONDictionary = [GRTJSONSerialization JSONDictionaryFromManagedObject:batman];
    
    NSDictionary *expectedDictionary = @{
        @"id": @"1699",
        @"name": @"Batman",
        @"real_name": @"Bruce Wayne",
        @"powers": @[
            @{
                @"id": @"4",
                @"name": @"Agility"
            },
            @{
                @"id": @"9",
                @"name": @"Insanely Rich"
            }
        ],
        @"publisher": @{
            @"id": @"10",
            @"name": @"DC Comics"
        }
    };
    
    XCTAssertEqualObjects(expectedDictionary, JSONDictionary, @"should serialize an initialized managed object to JSON dictionary");
}

- (void)testJSONDictionaryFromEmptyManagedObject {
    GRTCharacter *batman = [NSEntityDescription insertNewObjectForEntityForName:@"Character" inManagedObjectContext:self.context];
    NSDictionary *JSONDictionary = [GRTJSONSerialization JSONDictionaryFromManagedObject:batman];
    
    NSDictionary *expectedDictionary = @{
        @"id": NSNull.null,
        @"name": NSNull.null,
        @"real_name": NSNull.null,
        @"powers": @[],
        @"publisher": NSNull.null
    };
    
    XCTAssertEqualObjects(expectedDictionary, JSONDictionary, @"should serialize an uninitialized managed object to JSON dictionary");
}

- (void)testJSONDictionaryFromManagedObjectWithNestedDictionaries {
    NSEntityDescription *entity = self.store.managedObjectModel.entitiesByName[@"Character"];
    NSAttributeDescription *realNameAttribute = entity.attributesByName[@"realName"];
    
    realNameAttribute.userInfo = @{
        @"JSONKeyPath": @"real_name.name"
    };
    
    GRTCharacter *batman = [NSEntityDescription insertNewObjectForEntityForName:@"Character" inManagedObjectContext:self.context];
    batman.realName = @"Bruce Wayne";
    
    NSDictionary *JSONDictionary = [GRTJSONSerialization JSONDictionaryFromManagedObject:batman];
    
    NSDictionary *expectedDictionary = @{
        @"id": NSNull.null,
        @"name": NSNull.null,
        @"real_name": @{
                @"name": @"Bruce Wayne"
        },
        @"powers": @[],
        @"publisher": NSNull.null
    };
    
    XCTAssertEqualObjects(expectedDictionary, JSONDictionary, @"should serialize attributes with complex JSON key paths");
}

- (void)testJSONArrayFromManagedObjects {
    GRTCharacter *batman = [NSEntityDescription insertNewObjectForEntityForName:@"Character" inManagedObjectContext:self.context];
    batman.name = @"Batman";
    
    GRTCharacter *ironMan = [NSEntityDescription insertNewObjectForEntityForName:@"Character" inManagedObjectContext:self.context];
    ironMan.name = @"Iron Man";
    
    NSArray *JSONArray = [GRTJSONSerialization JSONArrayFromManagedObjects:@[batman, ironMan]];
    
    NSArray *expectedArray = @[
        @{
            @"id": NSNull.null,
            @"name": @"Batman",
            @"real_name": NSNull.null,
            @"powers": @[],
            @"publisher": NSNull.null
        },
        @{
            @"id": NSNull.null,
            @"name": @"Iron Man",
            @"real_name": NSNull.null,
            @"powers": @[],
            @"publisher": NSNull.null
        }
    ];
    
    XCTAssertEqualObjects(expectedArray, JSONArray, @"should serialize managed objects to JSON array");
}

@end
