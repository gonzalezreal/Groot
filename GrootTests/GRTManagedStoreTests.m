//
//  GRTManagedStoreTests.m
//  Groot
//
//  Created by Guillermo Gonzalez on 08/07/15.
//  Copyright (c) 2015 Guillermo Gonzalez. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <Groot/Groot.h>

#import "GRTModels.h"

@interface GRTManagedStoreTests : XCTestCase

@property (copy, nonatomic, nonnull) NSMutableArray *fileURLs;

@end

@implementation GRTManagedStoreTests

- (NSArray * __nonnull)fileURLs {
    if (_fileURLs == nil) {
        _fileURLs = [NSMutableArray array];
    }
    
    return _fileURLs;
}

- (void)tearDown {
    for (NSURL *URL in self.fileURLs) {
        [[NSFileManager defaultManager] removeItemAtURL:URL error:nil];
    }
    [super tearDown];
}

- (void)testInMemoryStore {
    NSManagedObjectModel *model = [NSManagedObjectModel grt_testModel];
    
    NSError *error = nil;
    GRTManagedStore *store = [[GRTManagedStore alloc] initWithModel:model error:&error];
    XCTAssertNil(error);
    
    NSPersistentStore *persistentStore = store.persistentStoreCoordinator.persistentStores[0];
    XCTAssertEqual(NSInMemoryStoreType, persistentStore.type);
}

- (void)testStoreWithCacheName {
    NSManagedObjectModel *model = [NSManagedObjectModel grt_testModel];
    
    NSError *error = nil;
    GRTManagedStore *store = [[GRTManagedStore alloc] initWithCacheName:@"Test.data" model:model error:&error];
    XCTAssertNil(error);
    
    NSString *bundleIdentifier = [NSBundle bundleForClass:[GRTManagedStore class]].bundleIdentifier;
    NSURL *expectedURL = [[NSFileManager defaultManager] URLForDirectory:NSCachesDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:&error];
    XCTAssertNil(error);
    
    expectedURL = [expectedURL URLByAppendingPathComponent:bundleIdentifier];
    expectedURL = [expectedURL URLByAppendingPathComponent:@"Test.data"];
    XCTAssertEqualObjects(expectedURL, store.URL);
    
    [self.fileURLs addObject:store.URL];
}

- (void)testContextWithConcurrencyType {
    NSManagedObjectModel *model = [NSManagedObjectModel grt_testModel];
    
    NSError *error = nil;
    GRTManagedStore *store = [[GRTManagedStore alloc] initWithModel:model error:&error];
    XCTAssertNil(error);
    
    NSManagedObjectContext *context = [store contextWithConcurrencyType:NSMainQueueConcurrencyType];
    XCTAssertEqualObjects(store.persistentStoreCoordinator, context.persistentStoreCoordinator);
    XCTAssertEqual(NSMainQueueConcurrencyType, context.concurrencyType);
}

@end
