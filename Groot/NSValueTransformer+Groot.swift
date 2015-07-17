// NSValueTransformer+Groot.swift
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

import Foundation

public extension NSValueTransformer {
    /**
     Registers a value transformer with a given name and transform function.
    
     :param: name The name of the transformer.
     :param: transform The function that performs the transformation.
    */
    class func setValueTransformerWithName<T, U>(name: String, transform: (T) -> (U?)) {
        grt_setValueTransformerWithName(name) { value in
            (value as? T).flatMap {
                transform($0) as? AnyObject
            }
        }
    }
    
    /**
     Registers a reversible value transformer with a given name and transform functions.
    
     :param: name The name of the transformer.
     :param: transform The function that performs the forward transformation.
     :param: reverseTransform The function that performs the reverse transformation.
    */
    class func setValueTransformerWithName<T, U>(name: String, transform: (T) -> (U?), reverseTransform: (U) -> (T?)) {
        grt_setValueTransformerWithName(name, transformBlock: { value in
            return (value as? T).flatMap {
                transform($0) as? AnyObject
            }
            }, reverseTransformBlock: { value in
                return (value as? U).flatMap {
                    reverseTransform($0) as? AnyObject
                }
        })
    }
    
    /**
     Registers an entity mapper with a given name and map block.
    
     An entity mapper maps a JSON dictionary to an entity name.
    
     Entity mappers can be associated with abstract core data entities in the user info
     dictionary by using the `entityMapperName` key.
    
     :param: name The name of the mapper.
     :param: map The function that performs the mapping.
    */
    class func setEntityMapperWithName(name: String, map: ([String: AnyObject]) -> (String?)) {
        grt_setEntityMapperWithName(name) { value in
            if let dictionary = value as? [String: AnyObject] {
                return map(dictionary)
            }
            return nil
        }
    }
}
