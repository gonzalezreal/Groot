// NSPropertyDescription+Groot.m
//
// Copyright (c) 2014 Guillermo Gonzalez
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

#import "NSPropertyDescription+Groot.h"
#import "GRTConstants.h"

static BOOL GRTIsNullKeyPath(NSString *keyPath) {
    return [keyPath isEqual:NSNull.null] || [keyPath isEqualToString:@"null"];
}

@implementation NSPropertyDescription (Groot)

- (NSString *)grt_JSONKeyPath {
    NSString *JSONKeyPath = self.userInfo[GRTJSONKeyPathKey];
    
    if (GRTIsNullKeyPath(JSONKeyPath)) {
        return nil;
    }
    
    return JSONKeyPath ? : self.name;
}

- (BOOL) grt_identityAttributeRelated
{
	return [self.userInfo[GRTIdentityAttributeRelatedKey] boolValue];
}
@end
