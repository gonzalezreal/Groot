// ValueTransformer.swift
// Groot
//
// Copyright (c) 2015 Guillermo Gonzalez
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

import Foundation

private class ValueTransformer: NSValueTransformer {
    let transform: (AnyObject?) -> (AnyObject?)
    
    init(transform: (AnyObject?) -> (AnyObject?)) {
        self.transform = transform
    }
    
    // MARK: NSValueTransformer
    
    override class func allowsReverseTransformation() -> Bool {
        return false;
    }
    
    override class func transformedValueClass() -> AnyClass {
        return NSObject.self
    }
    
    override func transformedValue(value: AnyObject?) -> AnyObject? {
        return transform(value)
    }
}

private class ReversibleValueTransformer: ValueTransformer {
    let reverseTransform: (AnyObject?) -> (AnyObject?)
    
    init(transform: (AnyObject?) -> (AnyObject?), reverseTransform: (AnyObject?) -> (AnyObject?)) {
        self.reverseTransform = reverseTransform
        super.init(transform: transform)
    }
    
    // MARK: NSValueTransformer
    
    override class func allowsReverseTransformation() -> Bool {
        return true;
    }
    
    override func reverseTransformedValue(value: AnyObject?) -> AnyObject? {
        return reverseTransform(value)
    }
}

public extension NSValueTransformer {
    /**
     Registers a value transformer with a given name and transform function.
    
     :param: name The name of the transformer.
     :param: transform The function that performs the transformation.
     */
    class func setValueTransformerWithName<T, U>(name: String, transform: (T) -> (U?)) {
        let transformer = ValueTransformer { value in
            if let v = value as? T {
                if let r: AnyObject? = transform(v) as? AnyObject? {
                    return r
                }
            }
            
            return nil
        }
        
        self.setValueTransformer(transformer, forName: name)
    }
    
    /**
     Registers a reversible value transformer with a given name and transform functions.
    
     :param: name The name of the transformer.
     :param: transform The function that performs the forward transformation.
     :param: reverseTransform The function that performs the reverse transformation.
     */
    class func setValueTransformerWithName<T, U>(name: String, transform: (T) -> (U?), reverseTransform: (U) -> (T?)) {
        let transformer = ReversibleValueTransformer(transform: { value in
            if let v = value as? T {
                if let r: AnyObject? = transform(v) as? AnyObject? {
                    return r
                }
            }
            
            return nil
        }, reverseTransform: { value in
            if let v = value as? U {
                if let r: AnyObject? = reverseTransform(v) as? AnyObject? {
                    return r
                }
            }
            
            return nil
        })
        
        self.setValueTransformer(transformer, forName: name)
    }
}
