//
//  Models.swift
//  Groot
//
//  Created by Guillermo Gonzalez on 20/09/16.
//  Copyright © 2016 Guillermo Gonzalez. All rights reserved.
//

import CoreData

final class Character: NSManagedObject {

    @NSManaged var identifier: Int
    @NSManaged var name: String
    @NSManaged var realName: String
    @NSManaged var publisher: Publisher?
    @NSManaged var powers: Set<Power>
}

final class Publisher: NSManagedObject {

    @NSManaged var identifier: Int
    @NSManaged var name: String
    @NSManaged var characters: Set<Character>
}

final class Power: NSManagedObject {

    @NSManaged var identifier: Int
    @NSManaged var name: String
    @NSManaged var characters: Set<Character>
}

final class Container: NSManagedObject {

    @NSManaged var abstracts: Set<Abstract>
}

class Abstract: NSManagedObject {

    @NSManaged var identifier: Int
    @NSManaged var container: Container?
}

final class ConcreteA: Abstract {

    @NSManaged var foo: String
}

final class ConcreteB: Abstract {

    @NSManaged var bar: String
}

final class Card: NSManagedObject {

    @NSManaged var suit: String
    @NSManaged var value: String
    @NSManaged var numberOfTimesPlayed: Int
}

extension NSManagedObjectModel {

    static var testModel: NSManagedObjectModel {
        let bundle = Bundle(for: Character.self)
        return NSManagedObjectModel.mergedModel(from: [bundle])!
    }
}
