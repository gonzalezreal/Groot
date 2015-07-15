//
//  NSData+Resource.h
//  Groot
//
//  Created by Guillermo Gonzalez on 15/07/15.
//  Copyright (c) 2015 Guillermo Gonzalez. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSData (Resource)

+ (nullable instancetype)grt_dataWithContentsOfResource:(NSString *)resource;

@end

NS_ASSUME_NONNULL_END
