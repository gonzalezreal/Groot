//
//  NSError+Groot.swift
//  Groot
//
//  Created by Guille Gonzalez on 29/03/15.
//  Copyright (c) 2015 Guille Gonzalez. All rights reserved.
//

import Foundation

public let errorDomain = "com.groot.error"

public enum Error : Int {
    case InvalidJSONObject = 1
    case EntityNotFound
    case IdentityNotFound
}

extension NSError {
    internal convenience init(code: Groot.Error, localizedDescription: String) {
        let userInfo = [NSLocalizedDescriptionKey: localizedDescription]
        self.init(domain: Groot.errorDomain, code: code.rawValue, userInfo: userInfo)
    }
}
