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

@interface GRTJSONSerializationTests : XCTestCase

@property (strong, nonatomic) GRTManagedStore *store;
@property (strong, nonatomic) NSManagedObjectContext *context;

@end

@implementation GRTJSONSerializationTests

- (void)setUp {
    [super setUp];
    
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSManagedObjectModel *model = [NSManagedObjectModel mergedModelFromBundles:@[bundle]];
    
    self.store = [GRTManagedStore managedStoreWithModel:model];
    self.context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    self.context.persistentStoreCoordinator = self.store.persistentStoreCoordinator;
}

- (void)tearDown {
    self.store = nil;
    [super tearDown];
}

- (void)testInsertObject {
    NSDictionary *batmanJSON = @{
        @"name": @"Batman",
        @"real_name": @"Bruce Wayne",
        @"id": @1699,
        @"powers": @[
            @{
                @"id": @4,
                @"name": @"Agility"
            },
            NSNull.null,
            @{
                @"id": @9,
                @"name": @"Insanely Rich"
            }
        ],
        @"publisher": @{
            @"id": @10,
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

- (void)testMergeObject {
    NSDictionary *batmanJSON = @{
        @"id": @1699,
        @"name": @"Batman",
        @"real_name": @"Bruce Wayne",
        @"powers": @[
            @{
                @"id": @4,
                @"name": @"Agility"
            },
            NSNull.null,
            @{
                @"id": @9,
                @"name": @"Insanely Rich"
            }
        ],
        @"publisher": @{
            @"id": @10,
            @"name": @"DC"
        }
    };
    
    NSError *error = nil;
    [GRTJSONSerialization mergeObjectForEntityName:@"Character" fromJSONDictionary:batmanJSON inManagedObjectContext:self.context error:&error];
    XCTAssertNil(error, @"shouldn't return an error");
    
    NSArray *updateJSON = @[
        @{
            @"id": @1699,
            @"real_name": NSNull.null,  // Should reset Batman real name
            @"publisher" : @{
                @"id": @10,
                @"name": @"DC Comics"   // Should update the publisher name
            }
        },
        @{
            @"id": @1455,
            @"name": @"Iron Man",
            @"real_name": @"Tony Stark",
            @"powers": @[
                @{
                    @"id": @31,
                    @"name": @"Power Suit"
                },
                @{
                    @"id": @9,
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

@end
