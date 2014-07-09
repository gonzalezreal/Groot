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
@dynamic birthday;
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
