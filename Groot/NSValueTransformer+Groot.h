// NSValueTransformer+Groot.h
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

#import <Foundation/Foundation.h>

typedef __nullable id (^GRTTransformBlock)(__nonnull id value);

@interface NSValueTransformer (Groot)

/**
 Registers a value transformer with a given name and transform block.
 
 @param name The name of the transformer.
 @param transformBlock The block that performs the transformation.
 */
+ (void)grt_setValueTransformerWithName:(nonnull NSString *)name
                         transformBlock:(nonnull GRTTransformBlock)transformBlock;

/**
 Registers a reversible value transformer with a given name and transform blocks.
 
 @param name The name of the transformer.
 @param transformBlock The block that performs the forward transformation.
 @param reverseTransformBlock The block that performs the reverse transformation.
 */
+ (void)grt_setValueTransformerWithName:(nonnull NSString *)name
                         transformBlock:(nonnull GRTTransformBlock)transformBlock
                  reverseTransformBlock:(nonnull GRTTransformBlock)reverseTransformBlock;

@end
