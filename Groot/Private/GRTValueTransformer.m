// GRTValueTransformer.m
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

#import "GRTValueTransformer.h"

#pragma mark - GRTValueTransformer

@interface GRTValueTransformer ()

@property (copy, nonatomic, nonnull) GRTValueTransformerBlock transformBlock;

@end

@implementation GRTValueTransformer

- (nonnull instancetype)initWithBlock:(nonnull GRTValueTransformerBlock)block {
    self = [super init];
    if (self) {
        self.transformBlock = block;
    }
    return self;
}

#pragma mark - NSValueTransformer

+ (BOOL)allowsReverseTransformation {
    return NO;
}

+ (Class)transformedValueClass {
    return NSObject.class;
}

- (id)transformedValue:(id)value {
    return self.transformBlock(value);
}

@end

#pragma mark - GRTReversibleValueTransformer

@interface GRTReversibleValueTransformer ()

@property (copy, nonatomic, nonnull) GRTValueTransformerBlock reverseTransformBlock;

@end

@implementation GRTReversibleValueTransformer

- (nonnull instancetype)initWithForwardBlock:(nonnull GRTValueTransformerBlock)forwardBlock
                                reverseBlock:(nonnull GRTValueTransformerBlock)reverseBlock
{
    self = [super initWithBlock:forwardBlock];
    if (self) {
        self.reverseTransformBlock = reverseBlock;
    }
    return self;
}

#pragma mark - NSValueTransformer

+ (BOOL)allowsReverseTransformation {
    return YES;
}

- (id)reverseTransformedValue:(id)value {
    return self.reverseTransformBlock(value);
}

@end
