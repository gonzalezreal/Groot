//
//  NSArray+DictionaryTransformer.m
//  Groot
//
//  Created by Guillermo Gonzalez on 05/08/15.
//  Copyright (c) 2015 Guillermo Gonzalez. All rights reserved.
//

#import "NSArray+DictionaryTransformer.h"

@implementation NSArray (DictionaryTransformer)

- (NSArray * __nonnull)grt_arrayByApplyingDictionaryTransformer:(NSValueTransformer * __nonnull)valueTransformer {    
    NSMutableArray *transformedArray = [NSMutableArray arrayWithCapacity:self.count];
    
    for (id object in self) {
        id transformedObject = nil;
        
        if ([object isKindOfClass:[NSDictionary class]]) {
            transformedObject = [valueTransformer transformedValue:object];
        }
        
        if (transformedObject != nil) {
            [transformedArray addObject:transformedObject];
        } else {
            [transformedArray addObject:object];
        }
    }
    
    return transformedArray;
}

@end
