//
//  GRTJSONSerializationTests.m
//  Groot
//
//  Created by guille on 03/07/14.
//  Copyright (c) 2014 Guillermo Gonzalez. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <Groot/Groot.h>

#import "NSData+Resource.h"
#import "GRTModels.h"

@interface GRTJSONSerializationTests : XCTestCase

@property (strong, nonatomic) GRTManagedStore *store;
@property (strong, nonatomic) NSManagedObjectContext *context;

@end

@implementation GRTJSONSerializationTests

- (void)setUp {
    [super setUp];
    
    self.store = [[GRTManagedStore alloc] initWithModel:[NSManagedObjectModel grt_testModel] error:nil];
    XCTAssertNotNil(self.store);
    
    self.context = [self.store contextWithConcurrencyType:NSMainQueueConcurrencyType];
    
    [NSValueTransformer grt_setValueTransformerWithName:@"GrootTests.Transformer" transformBlock:^id(NSString *value) {
        return @([value integerValue]);
    } reverseTransformBlock:^id(NSNumber *value) {
        return [value stringValue];
    }];
    
    [NSValueTransformer grt_setEntityMapperWithName:@"GrootTests.Abstract" mapBlock:^NSString *(NSDictionary *JSONDictionary) {
        NSDictionary *entityMapping = @{
            @"A": @"ConcreteA",
            @"B": @"ConcreteB"
        };
        NSString *type = JSONDictionary[@"type"];
        return entityMapping[type];
    }];
}

- (void)tearDown {
    self.store = nil;
    self.context = nil;
    
    [NSValueTransformer setValueTransformer:nil forName:@"GrootTests.Transformer"];
    
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
    GRTCharacter *batman = [GRTJSONSerialization objectWithEntityName:@"Character" fromJSONDictionary:batmanJSON inContext:self.context error:&error];
    XCTAssertNil(error, @"shouldn't return an error");
    
    XCTAssertEqualObjects(@1699, batman.identifier, @"should serialize attributes");
    XCTAssertEqualObjects(@"Batman", batman.name, @"should serialize attributes");
    XCTAssertEqualObjects(@"Bruce Wayne", batman.realName, @"should serialize attributes");
    
    XCTAssertEqual(2U, batman.powers.count, "should serialize to-many relationships");
    
    GRTPower *agility = batman.powers[0];
    
    XCTAssertEqualObjects(@4, agility.identifier, @"should serialize to-many relationships");
    XCTAssertEqualObjects(@"Agility", agility.name, @"should serialize to-many relationships");
    
    GRTPower *wealth = batman.powers[1];
    
    XCTAssertEqualObjects(@9, wealth.identifier, @"should serialize to-many relationships");
    XCTAssertEqualObjects(@"Insanely Rich", wealth.name, @"should serialize to-many relationships");
    
    GRTPublisher *publisher = batman.publisher;
    
    XCTAssertNotNil(publisher, @"should serialize to-one relationships");
    XCTAssertEqualObjects(@10, publisher.identifier, @"should serialize to-one relationships");
    XCTAssertEqualObjects(@"DC Comics", publisher.name, @"should serialize to-one relationships");
}

- (void)testInsertInvalidToOneRelationship {
    NSDictionary *invalidBatman = @{
        @"id": @"1699",
        @"name": @"Batman",
        @"real_name": @"Bruce Wayne",
        @"publisher": @[@"DC"]  // This should be a JSON dictionary
    };
    
    NSError *error = nil;
    GRTCharacter *batman = [GRTJSONSerialization objectWithEntityName:@"Character" fromJSONDictionary:invalidBatman inContext:self.context error:&error];
    
    XCTAssertNil(batman, @"should return nil on error");
    XCTAssertNotNil(error, @"should return an error");
    XCTAssertEqualObjects(GRTErrorDomain, error.domain, @"should return a serialization error");
    XCTAssertEqual(GRTErrorInvalidJSONObject, error.code, @"should return an invalid JSON error");
}

- (void)testInsertInvalidToManyRelationship {
    NSDictionary *invalidBatman = @{
        @"id": @"1699",
        @"name": @"Batman",
        @"real_name": @"Bruce Wayne",
        @"powers": @{   // This should be a JSON array
            @"id": @"4",
            @"name": @"Agility"
        }
    };
    
    NSError *error = nil;
    GRTCharacter *batman = [GRTJSONSerialization objectWithEntityName:@"Character" fromJSONDictionary:invalidBatman inContext:self.context error:&error];
    
    XCTAssertNil(batman, @"should return nil on error");
    XCTAssertNotNil(error, @"should return an error");
    XCTAssertEqualObjects(GRTErrorDomain, error.domain, @"should return a serialization error");
    XCTAssertEqual(GRTErrorInvalidJSONObject, error.code, @"should return an invalid JSON error");
}

- (void)testMergeObject {
    NSDictionary *batmanJSON = @{
        @"id": @"1699",
        @"name": @"Batman",
        @"real_name": @"Guille Gonzalez",
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
    
    [GRTJSONSerialization objectWithEntityName:@"Character" fromJSONDictionary:batmanJSON inContext:self.context error:&error];
    XCTAssertNil(error);
    
    NSArray *updateJSON = @[
        @{
            @"id": @"1699",
            @"real_name": @"Bruce Wayne",  // Should update real name
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
    
    [GRTJSONSerialization objectsWithEntityName:@"Character" fromJSONArray:updateJSON inContext:self.context error:&error];
    XCTAssertNil(error);
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"identifier" ascending:YES];
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Character"];
    fetchRequest.sortDescriptors = @[sortDescriptor];
    
    NSArray *characters = [self.context executeFetchRequest:fetchRequest error:NULL];
    XCTAssertEqual(2U, characters.count, @"there should be 2 characters");
    
    GRTCharacter *ironMan = characters[0];
    
    XCTAssertEqualObjects(@"Iron Man", ironMan.name, @"should serialize attributes");
    XCTAssertEqualObjects(@1455, ironMan.identifier, @"should serialize attributes");
    XCTAssertEqualObjects(@"Tony Stark", ironMan.realName, @"should serialize attributes");
    
    GRTPower *powerSuit = ironMan.powers[0];
    
    XCTAssertEqualObjects(@31, powerSuit.identifier, @"should serialize to-many relationships");
    XCTAssertEqualObjects(@"Power Suit", powerSuit.name, @"should serialize to-many relationships");
    
    
    GRTPower *ironManRich = ironMan.powers[1];
    
    XCTAssertEqualObjects(@9, ironManRich.identifier, @"should serialize to-many relationships");
    XCTAssertEqualObjects(@"Filthy Rich", ironManRich.name, @"should serialize to-many relationships");
    
    GRTCharacter *batman = characters[1];
    
    XCTAssertEqualObjects(@"Batman", batman.name, @"should serialize attributes");
    XCTAssertEqualObjects(@1699, batman.identifier, @"should serialize attributes");
    XCTAssertEqualObjects(@"Bruce Wayne", batman.realName, @"should serialize attributes");
    
    GRTPower *agility = batman.powers[0];
    
    XCTAssertEqualObjects(@4, agility.identifier, @"should serialize to-many relationships");
    XCTAssertEqualObjects(@"Agility", agility.name, @"should serialize to-many relationships");
        
    GRTPower *batmanRich = batman.powers[1];
    
    XCTAssertEqualObjects(@9, batmanRich.identifier, @"should serialize to-many relationships");
    XCTAssertEqualObjects(@"Filthy Rich", batmanRich.name, @"should serialize to-many relationships");
    
    XCTAssertEqualObjects(batmanRich, ironManRich, @"should merge relationships properly");
    
    XCTAssertEqualObjects(@10, batman.publisher.identifier, @"should serialize to-one relationships");
    XCTAssertEqualObjects(@"DC Comics", batman.publisher.name, @"should serialize to-one relationships");
    
    fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Power"];
    NSUInteger powerCount = [self.context countForFetchRequest:fetchRequest error:NULL];
    XCTAssertEqual(3U, powerCount, @"there should be 3 power objects");
    
    fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Publisher"];
    NSUInteger publisherCount = [self.context countForFetchRequest:fetchRequest error:NULL];
    XCTAssertEqual(1U, publisherCount, @"there should be 1 publisher objects");
}

- (void)testValidationDuringMerge {
    // See https://github.com/gonzalezreal/Groot/issues/2
    
    NSData *data = [NSData grt_dataWithContentsOfResource:@"characters.json"];
    XCTAssertNotNil(data, @"characters.json not found");
    
    NSError *error = nil;
    [GRTJSONSerialization objectsWithEntityName:@"Character" fromJSONData:data inContext:self.context error:&error];
    XCTAssertNil(error);
    
    NSData *updatedData = [NSData grt_dataWithContentsOfResource:@"characters_update.json"];
    XCTAssertNotNil(updatedData, @"characters_update.json not found");
    
    [GRTJSONSerialization objectsWithEntityName:@"Character" fromJSONData:updatedData inContext:self.context error:&error];
    XCTAssertNotNil(error, "should return an error");
    XCTAssertEqualObjects(NSCocoaErrorDomain, error.domain, "should return a validation error");
    XCTAssertEqual(NSValidationMissingMandatoryPropertyError, error.code, "should return a validation error");
}

- (void)testMissingIdentityAttribute {
    NSEntityDescription *powerEntity = self.store.managedObjectModel.entitiesByName[@"Power"];
    powerEntity.userInfo = @{}; // Remove the identity attribute name from the entity
    
    NSDictionary *dictionary = @{
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
    
    NSError *error = nil;
    GRTCharacter *batman = [GRTJSONSerialization objectWithEntityName:@"Character" fromJSONDictionary:dictionary inContext:self.context error:&error];
    
    XCTAssertNil(batman);
    XCTAssertNotNil(error);
    
    XCTAssertEqualObjects(GRTErrorDomain, error.domain);
    XCTAssertEqual(GRTErrorIdentityNotFound, error.code, "should return an identity not found error");
}

- (void)testSerializationFromIdentifiers {
    NSArray *charactersJSON = @[@"1699", @"1455"];
    
    NSError *error = nil;
    NSArray *characters = [GRTJSONSerialization objectsWithEntityName:@"Character" fromJSONArray:charactersJSON inContext:self.context error:&error];
    XCTAssertNil(error, @"shouldn't return an error");
    
    XCTAssertEqual(2U, characters.count);
    
    GRTCharacter *character = characters[0];
    XCTAssertEqualObjects(@"Character", character.entity.name);
    XCTAssertEqualObjects(@1699, character.identifier);
    
    character = characters[1];
    XCTAssertEqualObjects(@"Character", character.entity.name);
    XCTAssertEqualObjects(@1455, character.identifier);
}

- (void)testRelationshipSerializationFromIdentifiers {
    NSDictionary *batmanJSON = @{
        @"name": @"Batman",
        @"real_name": @"Bruce Wayne",
        @"id": @"1699",
        @"powers": @[@"4", NSNull.null, @"9"],
        @"publisher": @"10"
    };
    
    NSArray *powersJSON = @[
        @{
            @"id": @"4",
            @"name": @"Agility"
        },
        @{
            @"id": @"9",
            @"name": @"Insanely Rich"
        }
    ];
    
    NSDictionary *publisherJSON = @{
        @"id": @"10",
        @"name": @"DC Comics"
    };
    
    NSError *error = nil;
    GRTCharacter *batman = [GRTJSONSerialization objectWithEntityName:@"Character" fromJSONDictionary:batmanJSON inContext:self.context error:&error];
    XCTAssertNil(error, @"shouldn't return an error");
    
    [GRTJSONSerialization objectsWithEntityName:@"Power" fromJSONArray:powersJSON inContext:self.context error:&error];
    XCTAssertNil(error, @"shouldn't return an error");
    
    [GRTJSONSerialization objectWithEntityName:@"Publisher" fromJSONDictionary:publisherJSON inContext:self.context error:&error];
    XCTAssertNil(error, @"shouldn't return an error");
    
    XCTAssertEqual(2U, batman.powers.count, "should serialize to-many relationships");
    
    GRTPower *agility = batman.powers[0];
    
    XCTAssertEqualObjects(@4, agility.identifier, @"should serialize to-many relationships");
    XCTAssertEqualObjects(@"Agility", agility.name, @"should serialize to-many relationships");
    
    GRTPower *wealth = batman.powers[1];
    
    XCTAssertEqualObjects(@9, wealth.identifier, @"should serialize to-many relationships");
    XCTAssertEqualObjects(@"Insanely Rich", wealth.name, @"should serialize to-many relationships");
    
    GRTPublisher *publisher = batman.publisher;
    
    XCTAssertNotNil(publisher, @"should serialize to-one relationships");
    XCTAssertEqualObjects(@10, publisher.identifier, @"should serialize to-one relationships");
    XCTAssertEqualObjects(@"DC Comics", publisher.name, @"should serialize to-one relationships");
}

- (void)testSerializationFromIdentifiersFailsWithoutIdentityAttribute {
    NSEntityDescription *characterEntity = self.store.managedObjectModel.entitiesByName[@"Character"];
    characterEntity.userInfo = @{}; // Remove the identity attribute name from the entity
    
    NSArray *charactersJSON = @[@"1699", @"1455"];
    
    NSError *error = nil;
    NSArray *characters = [GRTJSONSerialization objectsWithEntityName:@"Character" fromJSONArray:charactersJSON inContext:self.context error:&error];
    
    XCTAssertNil(characters);
    XCTAssertNotNil(error);
    
    XCTAssertEqualObjects(GRTErrorDomain, error.domain);
    XCTAssertEqual(GRTErrorIdentityNotFound, error.code, "should return an identity not found error");
}

- (void)testSerializationFromIdentifiersValidatesValues {
    NSArray *charactersJSON = @[@"1699", [NSValue valueWithRange:NSMakeRange(0, 0)]];
    
    NSError *error = nil;
    NSArray *characters = [GRTJSONSerialization objectsWithEntityName:@"Character" fromJSONArray:charactersJSON inContext:self.context error:&error];
    
    XCTAssertNil(characters);
    XCTAssertNotNil(error);
    XCTAssertEqualObjects(NSCocoaErrorDomain, error.domain);
    XCTAssertEqual(NSValidationMissingMandatoryPropertyError, error.code);
}

- (void)testSerializationWithEntityInheritance {
    NSData *data = [NSData grt_dataWithContentsOfResource:@"container.json"];
    XCTAssertNotNil(data, @"container.json not found");
    
    NSError *error = nil;
    NSArray *objects = [GRTJSONSerialization objectsWithEntityName:@"Container" fromJSONData:data inContext:self.context error:&error];
    XCTAssertNil(error);
    XCTAssertEqual(1U, objects.count);
    
    GRTContainer *container = objects[0];
    
    GRTConcreteA *concreteA = container.abstracts[0];
    XCTAssertEqualObjects(@"ConcreteA", concreteA.entity.name);
    XCTAssertEqualObjects(@1, concreteA.identifier);
    XCTAssertEqualObjects(@"this is A", concreteA.foo);
    
    GRTConcreteB *concreteB = container.abstracts[1];
    XCTAssertEqualObjects(@"ConcreteB", concreteB.entity.name);
    XCTAssertEqualObjects(@2, concreteB.identifier);
    XCTAssertEqualObjects(@"this is B", concreteB.bar);
    
    NSDictionary *updateConcreteA = @{
        @"id": @1,
        @"foo": @"A has been updated"
    };
    
    concreteA = [GRTJSONSerialization objectWithEntityName:@"Abstract" fromJSONDictionary:updateConcreteA inContext:self.context error:&error];
    XCTAssertNil(error);
    XCTAssertEqualObjects(@"ConcreteA", concreteA.entity.name);
    XCTAssertEqualObjects(@1, concreteA.identifier);
    XCTAssertEqualObjects(@"A has been updated", concreteA.foo);
}

- (void)testSerializationToJSON {
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
    
    GRTCharacter *ironMan = [NSEntityDescription insertNewObjectForEntityForName:@"Character" inManagedObjectContext:self.context];
    ironMan.name = @"Iron Man";
    
    NSArray *JSONArray = [GRTJSONSerialization JSONArrayFromObjects:@[batman, ironMan]];
    
    NSArray *expectedArray = @[
        @{
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

- (void)testSerializationToJSONWithNestedDictionaries {
    NSEntityDescription *entity = self.store.managedObjectModel.entitiesByName[@"Character"];
    NSAttributeDescription *realNameAttribute = entity.attributesByName[@"realName"];
    
    realNameAttribute.userInfo = @{
        @"JSONKeyPath": @"real_name.foo.bar.name"
    };
    
    GRTCharacter *batman = [NSEntityDescription insertNewObjectForEntityForName:@"Character" inManagedObjectContext:self.context];
    batman.realName = @"Bruce Wayne";
    
    NSDictionary *JSONDictionary = [GRTJSONSerialization JSONDictionaryFromObject:batman];
    
    NSDictionary *expectedDictionary = @{
        @"id": NSNull.null,
        @"name": NSNull.null,
        @"real_name": @{
                @"foo": @{
                        @"bar": @{
                            @"name": @"Bruce Wayne"
                        }
                }
        },
        @"powers": @[],
        @"publisher": NSNull.null
    };
    
    XCTAssertEqualObjects(expectedDictionary, JSONDictionary, @"should serialize attributes with complex JSON key paths");
}

@end
