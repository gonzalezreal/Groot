//
//  NSManagedObject+GrootPublic.h
//  Groot
//
//  Created by Manuel García-Estañ on 20/12/2018.
//  Copyright © 2018 Guillermo Gonzalez. All rights reserved.
//

#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSManagedObject (GrootPublic)
- (void) grt_awakeFromInsert;
@end

NS_ASSUME_NONNULL_END
