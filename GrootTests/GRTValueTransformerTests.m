//
//  GRTValueTransformerTests.m
//  Groot
//
//  Created by guille on 11/07/14.
//  Copyright (c) 2014 Guillermo Gonzalez. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "GRTValueTransformer.h"

@interface GRTValueTransformerTests : XCTestCase

@end

@implementation GRTValueTransformerTests

- (void)testTransformerWithBlock {
    GRTValueTransformer *transformer = [[GRTValueTransformer alloc] initWithBlock:^id(NSNumber *value) {
        return [value stringValue];
    }];
    
    XCTAssertFalse([transformer.class allowsReverseTransformation], @"should not allow reverse transformation");
    XCTAssertEqualObjects(@"42", [transformer transformedValue:@42], @"should call the transform block");
}

- (void)testReversibleTransformerWithForwardAndReverseBlock {
    GRTReversibleValueTransformer *transformer = [[GRTReversibleValueTransformer alloc] initWithForwardBlock:^id(NSNumber *value) {
        return [value stringValue];
    } reverseBlock:^id(NSString *value) {
        return @([value integerValue]);
    }];
    
    XCTAssertTrue([transformer.class allowsReverseTransformation], @"should allow reverse transformation");
    XCTAssertEqualObjects(@"42", [transformer transformedValue:@42], @"should call the forward block");
    XCTAssertEqualObjects(@42, [transformer reverseTransformedValue:@"42"], @"should call the reverse block");
}

@end
