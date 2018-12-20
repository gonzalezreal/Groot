//
//  NSManagedObject+GrootPublic.m
//  Groot
//
//  Created by Manuel García-Estañ on 20/12/2018.
//  Copyright © 2018 Guillermo Gonzalez. All rights reserved.
//

#import "NSManagedObject+GrootPublic.h"

@implementation NSManagedObject (GrootPublic)

/**
 Called just after the object has been inserted or updated using Groot.
 */
- (void)grt_awakeFromInsert {
	// Empty on purpose. It is intended to be subclassed
}
@end
