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

@property (nonatomic, retain, nonnull) NSNumber *identifier;
@property (nonatomic, retain, nonnull) NSString *name;
@property (nonatomic, retain, nonnull) NSString *realName;
@property (nonatomic, retain, nullable) NSOrderedSet *powers;
@property (nonatomic, retain, nullable) GRTPublisher *publisher;

@end

@interface GRTPublisher : NSManagedObject

@property (nonatomic, retain, nonnull) NSNumber *identifier;
@property (nonatomic, retain, nonnull) NSString *name;
@property (nonatomic, retain, nullable) NSSet *characters;

@end

@interface GRTPower : NSManagedObject

@property (nonatomic, retain, nonnull) NSNumber *identifier;
@property (nonatomic, retain, nonnull) NSString *name;
@property (nonatomic, retain, nullable) NSSet *characters;

@end

@interface NSManagedObjectModel (GrootTests)

+ (nonnull instancetype)grt_testModel;

@end
