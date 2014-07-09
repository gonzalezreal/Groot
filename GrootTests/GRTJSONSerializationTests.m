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
    NSDictionary *dictionary = @{
        @"name": @"Batman",
        @"real_name": NSNull.null,  // Intentionally set to null, I know it's Bruce Wayne...
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
    GRTCharacter *character = [GRTJSONSerialization insertObjectForEntityName:@"Character" fromJSONDictionary:dictionary inManagedObjectContext:self.context error:&error];
    XCTAssertNil(error, @"shouldn't return an error");
    
    XCTAssertEqualObjects(@"Character", character.entity.name, @"should serialize to the right entity");
    
    XCTAssertEqualObjects(@"Batman", character.name, @"should serialize attributes");
    XCTAssertEqualObjects(@1699, character.identifier, @"should serialize attributes");
    XCTAssertNil(character.realName, @"should serialize null values");
    
    GRTPower *power = character.powers[0];
    
    XCTAssertEqualObjects(@"Power", power.entity.name, @"should serialize to-many relationships");
    XCTAssertEqualObjects(@4, power.identifier, @"should serialize to-many relationships");
    XCTAssertEqualObjects(@"Agility", power.name, @"should serialize to-many relationships");
    
    power = character.powers[1];
    
    XCTAssertEqualObjects(@9, power.identifier, @"should serialize to-many relationships");
    XCTAssertEqualObjects(@"Insanely Rich", power.name, @"should serialize to-many relationships");
    
    XCTAssertEqualObjects(@"Publisher", character.publisher.entity.name, @"should serialize to-one relationships");
    XCTAssertEqualObjects(@10, character.publisher.identifier, @"should serialize to-one relationships");
    XCTAssertEqualObjects(@"DC Comics", character.publisher.name, @"should serialize to-one relationships");
}

@end
