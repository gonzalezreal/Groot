//
//  IdentityAttributteRelatedModels.swift
//  Groot
//
//  Created by Manue on 23/4/15.
//  Copyright (c) 2015 Guille Gonzalez. All rights reserved.
//

import CoreData

class IARCharacter: NSManagedObject {
	@NSManaged var identifier: String
	@NSManaged var name: String
	@NSManaged var publisher: IARPublisher?
}

class IARPublisher: NSManagedObject {
	@NSManaged var identifier: String
	@NSManaged var name: String
	@NSManaged var characters: NSSet?
}
