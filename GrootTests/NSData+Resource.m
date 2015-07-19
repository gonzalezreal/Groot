//
//  NSData+Resource.m
//  Groot
//
//  Created by Guillermo Gonzalez on 15/07/15.
//  Copyright (c) 2015 Guillermo Gonzalez. All rights reserved.
//

#import "NSData+Resource.h"

@interface Dummy : NSObject
@end

@implementation Dummy
@end

@implementation NSData (Resource)

+ (nullable instancetype)grt_dataWithContentsOfResource:(NSString * __nonnull)resource {
    NSBundle *bundle = [NSBundle bundleForClass:[Dummy class]];
    NSString *path = [bundle pathForResource:[resource stringByDeletingPathExtension] ofType:resource.pathExtension];
    
    return [self dataWithContentsOfFile:path];
}

@end
