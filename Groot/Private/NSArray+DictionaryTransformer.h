//
//  NSArray+DictionaryTransformer.h
//  Groot
//
//  Created by Guillermo Gonzalez on 05/08/15.
//  Copyright (c) 2015 Guillermo Gonzalez. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSArray (DictionaryTransformer)

- (NSArray *)grt_arrayByApplyingDictionaryTransformer:(NSValueTransformer *)valueTransformer;

@end

NS_ASSUME_NONNULL_END
