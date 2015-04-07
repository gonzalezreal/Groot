//
//  ValueTransformer.swift
//  Groot
//
//  Created by Guille Gonzalez on 28/03/15.
//  Copyright (c) 2015 Guille Gonzalez. All rights reserved.
//

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
            return flatMap(value as? T) {
                transform($0) as? AnyObject
            }
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
            return flatMap(value as? T) {
                transform($0) as? AnyObject
            }
        }, reverseTransform: { value in
            return flatMap(value as? U) {
                reverseTransform($0) as? AnyObject
            }
        })
        
        self.setValueTransformer(transformer, forName: name)
    }
}
