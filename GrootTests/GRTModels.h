//
//  GRTModels.h
//  Groot
//
//  Created by guille on 09/07/14.
//  Copyright (c) 2014 Guillermo Gonzalez. All rights reserved.
//

#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@class GRTPower, GRTPublisher;

@interface GRTCharacter : NSManagedObject

@property (nonatomic, retain) NSNumber *identifier;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *realName;
@property (nonatomic, retain, nullable) NSOrderedSet *powers;
@property (nonatomic, retain, nullable) GRTPublisher *publisher;

@end

@interface GRTPublisher : NSManagedObject

@property (nonatomic, retain) NSNumber *identifier;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain, nullable) NSSet *characters;

@end

@interface GRTPower : NSManagedObject

@property (nonatomic, retain) NSNumber *identifier;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain, nullable) NSSet *characters;

@end

@interface GRTContainer : NSManagedObject

@property (nonatomic, retain, nullable) NSOrderedSet *abstracts;

@end

@interface GRTAbstract : NSManagedObject

@property (nonatomic, retain) NSNumber *identifier;
@property (nonatomic, retain, nullable) GRTContainer *container;

@end

@interface GRTConcreteA : GRTAbstract

@property (nonatomic, retain) NSString *foo;

@end

@interface GRTConcreteB : GRTAbstract

@property (nonatomic, retain) NSString *bar;

@end

@interface GRTCard : NSManagedObject

@property (nonatomic, retain) NSString *suit;
@property (nonatomic, retain) NSString *value;
@property (nonatomic, retain) NSNumber *numberOfTimesPlayed;

@end

@interface NSManagedObjectModel (GrootTests)

+ (nonnull instancetype)grt_testModel;

@end

NS_ASSUME_NONNULL_END
