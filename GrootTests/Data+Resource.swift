//
//  Data+Resource.swift
//  Groot
//
//  Created by Guillermo Gonzalez on 20/09/16.
//  Copyright © 2016 Guillermo Gonzalez. All rights reserved.
//

import Foundation

extension Data {

    private class Dummy {}

    internal init?(resource: String) {

        let name = (resource as NSString).deletingPathExtension
        let type = (resource as NSString).pathExtension
        let bundle = Bundle(for: Dummy.self)

        guard let url = bundle.url(forResource: name, withExtension: type) else {
            return nil
        }

        try? self.init(contentsOf: url)
    }
}
