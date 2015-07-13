// GRTJSONSerialization.m
//
// Copyright (c) 2014-2015 Guillermo Gonzalez
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "GRTJSONSerialization.h"

NS_ASSUME_NONNULL_BEGIN

@implementation GRTJSONSerialization

+ (nullable NSArray *)objectsWithEntityName:(NSString *)entityName
                               fromJSONData:(NSData *)data
                                  inContext:(NSManagedObjectContext *)context
                                      error:(NSError * __nullable * __nullable)outError
{
    // TODO: implement
    return nil;
}

+ (nullable id)objectWithEntityName:(NSString *)entityName
                 fromJSONDictionary:(NSDictionary *)JSONDictionary
                          inContext:(NSManagedObjectContext *)context
                              error:(NSError * __nullable * __nullable)outError
{
    // TODO: implement
    return nil;
}

+ (nullable NSArray *)objectsWithEntityName:(NSString *)entityName
                              fromJSONArray:(NSArray *)JSONArray
                                  inContext:(NSManagedObjectContext *)context
                                      error:(NSError * __nullable * __nullable)outError
{
    // TODO: implement
    return nil;
}

+ (NSDictionary *)JSONDictionaryFromObject:(NSManagedObject *)object {
    // TODO: implement
    return nil;
}

+ (NSArray *)JSONArrayFromObjects:(NSManagedObject *)objects {
    // TODO: implement
    return nil;
}

@end

NS_ASSUME_NONNULL_END
