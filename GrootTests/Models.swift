//
//  Models.swift
//  Groot
//
//  Created by Guille Gonzalez on 29/03/15.
//  Copyright (c) 2015 Guille Gonzalez. All rights reserved.
//

import CoreData

class Character: NSManagedObject {
    @NSManaged var identifier: Int32
    @NSManaged var name: String
    @NSManaged var realName: String
    @NSManaged var powers: NSOrderedSet?
    @NSManaged var publisher: Publisher?
}

class Publisher: NSManagedObject {
    @NSManaged var identifier: Int32
    @NSManaged var name: String
    @NSManaged var characters: NSSet?
}

class Power: NSManagedObject {
    @NSManaged var identifier: Int32
    @NSManaged var name: String
    @NSManaged var characters: NSSet?
}
