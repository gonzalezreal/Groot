//
//  GRTModels.m
//  Groot
//
//  Created by guille on 09/07/14.
//  Copyright (c) 2014 Guillermo Gonzalez. All rights reserved.
//

#import "GRTModels.h"

@implementation GRTCharacter

@dynamic identifier;
@dynamic name;
@dynamic realName;
@dynamic powers;
@dynamic publisher;

@end

@implementation GRTPower

@dynamic identifier;
@dynamic name;
@dynamic characters;

@end

@implementation GRTPublisher

@dynamic identifier;
@dynamic name;
@dynamic characters;

@end

@implementation GRTContainer

@dynamic abstracts;

@end

@implementation GRTAbstract

@dynamic identifier;
@dynamic container;

@end

@implementation GRTConcreteA

@dynamic foo;

@end

@implementation GRTConcreteB

@dynamic bar;

@end

@implementation NSManagedObjectModel (GrootTests)

+ (nonnull instancetype)grt_testModel {
    NSBundle *bundle = [NSBundle bundleForClass:[GRTCharacter class]];
    return [NSManagedObjectModel mergedModelFromBundles:@[bundle]];
}

@end
