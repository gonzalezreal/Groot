//
//  SerializationTests.swift
//  Groot
//
//  Created by Guillermo Gonzalez on 20/09/16.
//  Copyright © 2016 Guillermo Gonzalez. All rights reserved.
//

import XCTest
import Groot

class SerializationTests: XCTestCase {

    var store: GRTManagedStore?
    var context: NSManagedObjectContext?

    override func setUp() {
        super.setUp()

        store = try? GRTManagedStore(model: NSManagedObjectModel.testModel)
        context = store?.context(with: .mainQueueConcurrencyType)

        ValueTransformer.setValueTransformer(
            withName: "GrootTests.Transformer",
            transform: { (value: String) in
                return Int(value)
            },
            reverseTransform: { (value: Int) in
                return String(value)
            });

        ValueTransformer.setEntityMapper(withName: "GrootTests.Abstract") { dictionary in
            guard let type = dictionary["type"] as? String else {
                return nil
            }

            switch type {
            case "A":
                return "ConcreteA"
            case "B":
                return "ConcreteB"
            default:
                return nil
            }
        }

        ValueTransformer.setDictionaryTransformer(withName: "GrootTests.DictionaryTransformer") { dictionary in
            var transformed = dictionary
            transformed["id"] = dictionary["legacy_id"]
            return transformed
        }
    }
    
    override func tearDown() {
        store = nil
        context = nil

        ValueTransformer.setValueTransformer(nil, forName: NSValueTransformerName("GrootTests.Transformer"))
        ValueTransformer.setValueTransformer(nil, forName: NSValueTransformerName("GrootTests.Abstract"))
        ValueTransformer.setValueTransformer(nil, forName: NSValueTransformerName("GrootTests.DictionaryTransformer"))

        super.tearDown()
    }

    func testInsertObject() {
        guard let context = context else {
            XCTFail()
            return
        }

        let batmanJSON: JSONDictionary = [
            "name": "Batman",
            "real_name": "Bruce Wayne",
            "id": "1699",
            "powers": [
                [
                    "id": "4",
                    "name": "Agility"
                ],
                NSNull(),
                [
                    "id": "9",
                    "name": "Insanely Rich"
                ]
            ],
            "publisher": [
                "id": "10",
                "name": "DC Comics"
            ]
        ]

        do {
            let batman: Character = try object(fromJSONDictionary: batmanJSON, inContext: context)

            XCTAssertEqual(1699, batman.identifier)
            XCTAssertEqual("Batman", batman.name)
            XCTAssertEqual("Bruce Wayne", batman.realName)

            let powers = batman.powers.sorted(by: identifierAscending)

            XCTAssertEqual(2, powers.count)
            XCTAssertEqual(4, powers[0].identifier)
            XCTAssertEqual("Agility", powers[0].name)
            XCTAssertEqual(9, powers[1].identifier)
            XCTAssertEqual("Insanely Rich", powers[1].name)

            guard let publisher = batman.publisher else {
                XCTFail()
                return
            }

            XCTAssertEqual(10, publisher.identifier)
            XCTAssertEqual("DC Comics", publisher.name)
        } catch {
            XCTFail("error: \(error)")
        }
    }

    func testInsertInvalidToOneRelationship() {
        guard let context = context else {
            XCTFail()
            return
        }

        let invalidBatman: JSONDictionary = [
            "id": "1699",
            "name": "Batman",
            "real_name": "Bruce Wayne",
            "publisher": ["DC"]  // This should be a JSON dictionary
        ]

        do {
            let _: Character = try object(fromJSONDictionary: invalidBatman, inContext: context)
            XCTFail("This should fail")
        } catch let error as NSError {
            XCTAssertEqual(GRTErrorDomain, error.domain)
            XCTAssertEqual(GRTError.invalidJSONObject.rawValue, error.code)
        }
    }

    func testInsertInvalidToManyRelationship() {
        guard let context = context else {
            XCTFail()
            return
        }

        let invalidBatman: JSONDictionary = [
            "id": "1699",
            "name": "Batman",
            "real_name": "Bruce Wayne",
            "powers": [   // This should be a JSON array
                "id": "4",
                "name": "Agility"
            ]
        ]

        do {
            let _: Character = try object(fromJSONDictionary: invalidBatman, inContext: context)
            XCTFail("This should fail")
        } catch let error as NSError {
            XCTAssertEqual(GRTErrorDomain, error.domain)
            XCTAssertEqual(GRTError.invalidJSONObject.rawValue, error.code)
        }
    }

    func testMergeObject() {
        guard let context = context else {
            XCTFail()
            return
        }

        let batmanJSON: JSONDictionary = [
            "id": "1699",
            "name": "Batman",
            "real_name": "Guille Gonzalez",
            "powers": [
                [
                    "id": "4",
                    "name": "Agility"
                ],
                NSNull(),
                [
                    "id": "9",
                    "name": "Insanely Rich"
                ]
            ],
            "publisher": [
                "id": "10",
                "name": "DC"
            ]
        ]

        guard let _: Character = try? object(fromJSONDictionary: batmanJSON, inContext: context) else {
            XCTFail()
            return
        }

        let updateJSON: JSONArray = [
            [
                "id": "1699",
                "real_name": "Bruce Wayne",  // Should update real name
                "publisher" : [
                    "id": "10",
                    "name": "DC Comics"   // Should update the publisher name
                ]
            ],
            [
                "id": "1455",
                "name": "Iron Man",
                "real_name": "Tony Stark",
                "powers": [
                    [
                        "id": "31",
                        "name": "Power Suit"
                    ],
                    [
                        "id": "9",
                        "name": "Filthy Rich" // Should update the 'Rich' power name
                    ]
                ],
                ]
        ]

        guard let _: [Character] = try? objects(fromJSONArray: updateJSON, inContext: context) else {
            XCTFail()
            return
        }

        let sortDescriptor = NSSortDescriptor(key: "identifier", ascending: true)
        let fetchRequest = NSFetchRequest<Character>(entityName: "Character")
        fetchRequest.sortDescriptors = [sortDescriptor]

        guard let characters = try? context.fetch(fetchRequest) else {
            XCTFail()
            return
        }

        XCTAssertEqual(2, characters.count)

        let ironMan = characters[0]

        XCTAssertEqual("Iron Man", ironMan.name)
        XCTAssertEqual(1455, ironMan.identifier)
        XCTAssertEqual("Tony Stark", ironMan.realName)

        var powers = ironMan.powers.sorted(by: identifierAscending)

        let ironManRich = powers[0];

        XCTAssertEqual(9, ironManRich.identifier)
        XCTAssertEqual("Filthy Rich", ironManRich.name)

        let powerSuit = powers[1]

        XCTAssertEqual(31, powerSuit.identifier)
        XCTAssertEqual("Power Suit", powerSuit.name)

        let batman = characters[1]

        XCTAssertEqual("Batman", batman.name)
        XCTAssertEqual(1699, batman.identifier)
        XCTAssertEqual("Bruce Wayne", batman.realName)

        powers = batman.powers.sorted(by: identifierAscending)

        let agility = powers[0]

        XCTAssertEqual(4, agility.identifier)
        XCTAssertEqual("Agility", agility.name)

        let batmanRich = powers[1]

        XCTAssertEqual(9, batmanRich.identifier)
        XCTAssertEqual("Filthy Rich", batmanRich.name)
        XCTAssertEqual(batmanRich, ironManRich)

        XCTAssertEqual(10, batman.publisher?.identifier)
        XCTAssertEqual("DC Comics", batman.publisher?.name)

        let powerCount = try? context.count(for: NSFetchRequest<Power>(entityName: "Power"))
        XCTAssertEqual(3, powerCount)

        let publisherCount = try? context.count(for: NSFetchRequest<Publisher>(entityName: "Publisher"))
        XCTAssertEqual(1, publisherCount)
    }

    func testValidationDuringMerge() {
        // See https://github.com/gonzalezreal/Groot/issues/2

        guard
            let data = Data(resource: "characters.json"),
            let updatedData = Data(resource: "characters_update.json"),
            let context = context else {
            XCTFail()
            return
        }

        do {
            let _: [Character] = try objects(fromJSONData: data, inContext: context)
        } catch {
            XCTFail("error: \(error)")
        }

        do {
            let _: [Character] = try objects(fromJSONData: updatedData, inContext: context)
            XCTFail("This should fail")
        } catch let error as NSError {
            XCTAssertEqual(NSCocoaErrorDomain, error.domain)
            XCTAssertEqual(NSValidationMissingMandatoryPropertyError, error.code)
        }
    }

    func testSerializationFromIdentifiers() {
        guard let context = context else {
            XCTFail()
            return
        }

        let json = ["1699", "1455"]

        do {
            let characters: [Character] = try objects(fromJSONArray: json, inContext: context)

            XCTAssertEqual(2, characters.count)

            XCTAssertEqual("Character", characters[0].entity.name)
            XCTAssertEqual(1699, characters[0].identifier)
            XCTAssertEqual("Character", characters[1].entity.name)
            XCTAssertEqual(1455, characters[1].identifier)
        } catch {
            XCTFail("error: \(error)")
        }
    }

    func testRelationshipSerializationFromIdentifiers() {
        guard let context = context else {
            XCTFail()
            return
        }

        let batmanJSON: JSONDictionary = [
            "name": "Batman",
            "real_name": "Bruce Wayne",
            "id": "1699",
            "powers": ["4", NSNull(), "9"],
            "publisher": "10"
        ]

        let powersJSON: JSONArray = [
            [
                "id": "4",
                "name": "Agility"
            ],
            [
                "id": "9",
                "name": "Insanely Rich"
            ]
        ]

        let publisherJSON: JSONDictionary = [
            "id": "10",
            "name": "DC Comics"
        ]

        do {
            let batman: Character = try object(fromJSONDictionary: batmanJSON, inContext: context)
            let _: [Power] = try objects(fromJSONArray: powersJSON, inContext: context)
            let _: Publisher = try object(fromJSONDictionary: publisherJSON, inContext: context)

            XCTAssertEqual(2, batman.powers.count)

            let powers = batman.powers.sorted(by: identifierAscending)

            let agility = powers[0]

            XCTAssertEqual(4, agility.identifier)
            XCTAssertEqual("Agility", agility.name)

            let wealth = powers[1]

            XCTAssertEqual(9, wealth.identifier)
            XCTAssertEqual("Insanely Rich", wealth.name)

            let publisher = batman.publisher

            XCTAssertEqual(10, publisher?.identifier)
            XCTAssertEqual("DC Comics", publisher?.name)
        } catch {
            XCTFail("error: \(error)")
        }
    }

    func testSerializationFromIdentifiersFailsWithoutIdentityAttribute() {
        guard let context = context else {
            XCTFail()
            return
        }

        let characterEntity = store?.managedObjectModel.entitiesByName["Character"]
        characterEntity?.userInfo = [:] // Remove the identity attribute name from the entity

        let json = ["1699", "1455"]

        do {
            let _: [Character] = try objects(fromJSONArray: json, inContext: context)
            XCTFail("This should fail")
        } catch let error as NSError {
            XCTAssertEqual(GRTErrorDomain, error.domain)
            XCTAssertEqual(GRTError.invalidJSONObject.rawValue, error.code)
        }
    }

    func testSerializationFromIdentifiersValidatesValues() {
        guard let context = context else {
            XCTFail()
            return
        }

        let json: JSONArray = ["1699", NSValue(range: NSRange(location: 0, length: 0))]

        do {
            let _: [Character] = try objects(fromJSONArray: json, inContext: context)
            XCTFail("This should fail")
        } catch let error as NSError {
            XCTAssertEqual(NSCocoaErrorDomain, error.domain)
            XCTAssertEqual(NSValidationMissingMandatoryPropertyError, error.code)
        }
    }

    func testSerializationWithEntityInheritance() {
        guard
            let data = Data(resource: "container.json"),
            let context = context else {
                XCTFail()
                return
        }

        do {
            let containers: [Container] = try objects(fromJSONData: data, inContext: context)
            XCTAssertEqual(1, containers.count)

            let abstracts = containers[0].abstracts.sorted(by: identifierAscending)

            let concreteA = abstracts[0] as? ConcreteA
            XCTAssertEqual("ConcreteA", concreteA?.entity.name)
            XCTAssertEqual(1, concreteA?.identifier)
            XCTAssertEqual("this is A", concreteA?.foo)

            let concreteB = abstracts[1] as? ConcreteB
            XCTAssertEqual("ConcreteB", concreteB?.entity.name)
            XCTAssertEqual(2, concreteB?.identifier)
            XCTAssertEqual("this is B", concreteB?.bar)

            let updateConcreteA: JSONDictionary = [
                "id": 1,
                "foo": "A has been updated"
            ]

            let _ = try object(withEntityName: "Abstract", fromJSONDictionary: updateConcreteA, inContext: context)

            XCTAssertEqual("A has been updated", concreteA?.foo)
        } catch {
            XCTFail("error: \(error)")
        }
    }

    func testSerializationWithDictionaryTransformer() {
        guard
            let context = context,
            let characterEntity = store?.managedObjectModel.entitiesByName["Character"] else {
            XCTFail()
            return
        }

        characterEntity.userInfo?["JSONDictionaryTransformerName"] = "GrootTests.DictionaryTransformer"

        let batmanJSON = [
            "name": "Batman",
            "real_name": "Bruce Wayne",
            "legacy_id": "1699",
        ]

        do {
            let batman: Character = try object(fromJSONDictionary: batmanJSON, inContext: context)

            XCTAssertEqual(1699, batman.identifier)
            XCTAssertEqual("Batman", batman.name)
            XCTAssertEqual("Bruce Wayne", batman.realName)
        } catch {
            XCTFail("error: \(error)")
        }
    }

    func testSerializationWithCompositeKey() {
        guard
            let context = context,
            let data = Data(resource: "cards.json"),
            let updatedData = Data(resource: "cards_update.json") else {
                XCTFail()
                return
        }

        do {
            let cards: [Card] = try objects(fromJSONData: data, inContext: context)

            XCTAssertEqual(2, cards.count)

            let threeOfDiamonds = cards[0]
            XCTAssertEqual(2, threeOfDiamonds.numberOfTimesPlayed)
            XCTAssertEqual("Diamonds", threeOfDiamonds.suit)
            XCTAssertEqual("Three", threeOfDiamonds.value)

            let jackOfHearts = cards[1]
            XCTAssertEqual(3, jackOfHearts.numberOfTimesPlayed)
            XCTAssertEqual("Hearts", jackOfHearts.suit)
            XCTAssertEqual("Jack", jackOfHearts.value)

            let updatedCards: [Card] = try objects(fromJSONData: updatedData, inContext: context)

            XCTAssertEqual(4, jackOfHearts.numberOfTimesPlayed)

            let threeOfClubs = updatedCards[1];
            XCTAssertEqual(1, threeOfClubs.numberOfTimesPlayed)
            XCTAssertEqual("Clubs", threeOfClubs.suit)
            XCTAssertEqual("Three", threeOfClubs.value)

            let fetchRequest = NSFetchRequest<Card>(entityName: "Card")
            let allCards = try context.fetch(fetchRequest)
            XCTAssertEqual(3, allCards.count)
        } catch {
            XCTFail("error: \(error)")
        }
    }

    func testSerializationToJSON() {
        guard let context = context else {
            XCTFail()
            return
        }

        let dc = NSEntityDescription.insertNewObject(
            forEntityName: "Publisher",
            into: context) as! Publisher
        dc.identifier = 10
        dc.name = "DC Comics"

        let agility = NSEntityDescription.insertNewObject(
            forEntityName: "Power",
            into: context) as! Power
        agility.identifier = 4
        agility.name = "Agility"

        let wealth = NSEntityDescription.insertNewObject(
            forEntityName: "Power",
            into: context) as! Power
        wealth.identifier = 9
        wealth.name = "Insanely Rich"

        let batman = NSEntityDescription.insertNewObject(
            forEntityName: "Character",
            into: context) as! Character
        batman.identifier = 1699
        batman.name = "Batman"
        batman.realName = "Bruce Wayne"
        batman.powers.insert(agility)
        batman.powers.insert(wealth)
        batman.publisher = dc

        let ironMan = NSEntityDescription.insertNewObject(
            forEntityName: "Character",
            into: context) as! Character
        ironMan.name = "Iron Man"

        let result = json(fromObjects: [batman, ironMan])

        let expectedResult: JSONArray = [
            [
                "id": "1699",
                "name": "Batman",
                "real_name": "Bruce Wayne",
                "powers": [
                    [
                        "id": "4",
                        "name": "Agility"
                    ],
                    [
                        "id": "9",
                        "name": "Insanely Rich"
                    ]
                ],
                "publisher": [
                    "id": "10",
                    "name": "DC Comics"
                ]
            ],
            [
                "id": NSNull(),
                "name": "Iron Man",
                "real_name": NSNull(),
                "powers": [],
                "publisher": NSNull()
            ]
        ]

        XCTAssertEqual(result as NSArray, expectedResult as NSArray)
    }

    func testSerializationToJSONWithNestedDictionaries() {
        guard let context = context else {
            XCTFail()
            return
        }

        let entity = store?.managedObjectModel.entitiesByName["Character"]
        entity?.attributesByName["realName"]?.userInfo = [
            "JSONKeyPath": "real_name.foo.bar.name"
        ]

        let batman = NSEntityDescription.insertNewObject(
            forEntityName: "Character",
            into: context) as! Character
        batman.realName = "Bruce Wayne"

        let result = json(fromObject: batman)

        let expectedResult: JSONDictionary = [
            "id": NSNull(),
            "name": NSNull(),
            "real_name": [
                "foo": [
                    "bar": [
                        "name": "Bruce Wayne"
                    ]
                ]
            ],
            "powers": [],
            "publisher": NSNull()
        ]

        XCTAssertEqual(result as NSDictionary, expectedResult as NSDictionary)
    }
}

private func identifierAscending(_ left: Power, right: Power) -> Bool {
    return left.identifier < right.identifier
}

private func identifierAscending(_ left: Abstract, right: Abstract) -> Bool {
    return left.identifier < right.identifier
}
