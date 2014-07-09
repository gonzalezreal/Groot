//
//  GRTModels.h
//  Groot
//
//  Created by guille on 09/07/14.
//  Copyright (c) 2014 Guillermo Gonzalez. All rights reserved.
//

#import <CoreData/CoreData.h>

@class GRTPower, GRTPublisher;

@interface GRTCharacter : NSManagedObject

@property (nonatomic, retain) NSNumber *identifier;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *realName;
@property (nonatomic, retain) NSDate *birthday;
@property (nonatomic, retain) NSOrderedSet *powers;
@property (nonatomic, retain) GRTPublisher *publisher;

@end

@interface GRTPower : NSManagedObject

@property (nonatomic, retain) NSNumber *identifier;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSSet *characters;

@end

@interface GRTPublisher : NSManagedObject

@property (nonatomic, retain) NSNumber *identifier;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSSet *characters;

@end
