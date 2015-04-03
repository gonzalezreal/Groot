# Groot
With Groot you can convert JSON dictionaries and arrays to and from Core Data managed objects.

## Requirements
Groot supports OS X 10.9+ and iOS 8.0+.

## Installation
### Cocoapods
Add the following to your `Podfile`:

``` ruby
pod 'Groot'
```

Then run `$ pod install`.

If you don't have CocoaPods installed or integrated into your project, you can learn how to do so [here](http://cocoapods.org).

### Carthage
Add the following to your `Cartfile`:

```
github “gonzalezreal/Groot”
```

Then run `$ carthage update`.

Follow the instructions in [Carthage’s README](https://github.com/Carthage/Carthage#adding-frameworks-to-an-application]) to add the framework to your project.

## Usage
Suppose you would like to convert the JSON returned by a Comic Database web service into your own model objects. The JSON could look something like this:

```json
[
    {
        "id": "1699",
        "name": "Batman",
        "powers": [
            {
                "id": "4",
                "name": "Agility"
            },
            {
                "id": "9",
                "name": "Insanely Rich"
            }
        ],
        "publisher": {
            "id": "10",
            "name": "DC Comics"
        },
        "real_name": "Bruce Wayne"
    },
]
```

You could model this in Core Data using 3 entities: Character, Power and Publisher.

<img src="https://cloud.githubusercontent.com/assets/373190/6988401/5346423a-da51-11e4-8bf1-a41da3a7372f.png" alt="Model" width=600 height=334/>

Next you need to specify how attributes and relationships should be mapped from the JSON. For this you can use the **user dictionary** provided in Core Data *entities*, *attributes* and *relationships*.

Note that you must explicitly specify every attribute or relationship that should be mapped. Any attribute or relationship omitted will not be considered for JSON serialization or deserialization.

To specify how an attribute or a relationship is mapped to JSON, use the `JSONKeyPath` key. Optionally you can use `JSONTransformerName` to specify the name of the value transformer that will be used to convert the JSON value for an attribute. If the specified transformer is reversible, it will also be used to convert the attribute value back to JSON.

For instance, you can specify that the `identifier` attribute will be mapped from the `id` JSON key path, and that its value will be transformed using an `NSValueTransformer` named `GrootTests.Transformer`

<img src="https://cloud.githubusercontent.com/assets/373190/6988412/78b00006-da51-11e4-908a-de40c99141e8.png" alt="Property User Info" width=260 height=338/>

### Installing a `NSValueTransformer`

The `identifier` attribute requires a `NSValuedTransformer` that transforms the string identifiers in the JSON to integer values. Fortunately, **Groot** provides an easy and safe way to create and install named `NSValueTransformer`s:

```swift
func toInt(value: String) -> Int? {
    return value.toInt()
}

func toString(value: Int) -> String? {
    return "\(value)"
}

NSValueTransformer.setValueTransformerWithName("GrootTests.Transformer",
	transform: toInt, reverseTransform: toString)
```

### Setting up a Core Data stack

The `ManagedStore` class lets you easily create and manage a Core Data stack. The following code creates a Core Data stack that will persist its data in the application `Library/Caches` directory:

```swift
var error: NSError? = nil

if let store = ManagedStore.storeWithCacheName("characters.db", error: &error) {
    let context = store.contextWithConcurrencyType(.MainQueueConcurrencyType)
    
    // Use the context...
}
```

### Importing JSON data

There are several options to import JSON into our Core Data model.

You can import raw JSON data coming from an external source:

```swift
func importJSON(data: NSData) {
    var error: NSError? = nil
    let characters: [Character]? = Groot.importJSONData(data,
        inContext: context, mergeChanges: false, error: &error)
    ...
}
```

Import a JSON dictionary:

```swift
let batmanJSON: JSONObject = [
    "name": "Batman",
    "real_name": "Bruce Wayne",
    "id": "1699",
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
]

let batman = Character.fromJSONObject(batmanJSON,
        inContext: context, mergeChanges: false, error: &error)
```

For more importing options check [Groot.swift](https://github.com/gonzalezreal/Groot/blob/swift/Groot/Groot.swift) and [NSEntityDescription+Groot.swift](https://github.com/gonzalezreal/Groot/blob/swift/Groot/NSEntityDescription%2BGroot.swift#L71)

### Merging data

When inserting data, Groot does not check if the serialized managed objects already exist and simply treats them as new.

If instead, you would like to merge (that is, create or update) the serialized managed objects, then you need to tell Groot how to uniquely identify your model objects. You can do that by associating the `identityAttribute` key with the name of an attribute in the *entity* user info dictionary.

<img src="https://cloud.githubusercontent.com/assets/373190/6988420/897c09e8-da51-11e4-986f-afedc9134b77.png" alt="Property User Info" width=257 height=311/>

In this sample, all of the models are identified by the `identifier` attribute.

To update the character we just inserted before we just need to set `mergeChanges:` to `true`:

```swift
let batmanJSON: JSONObject = [
    "name": "Batman",
    "real_name": "Guille Gonzalez",
    "id": "1699",
    "powers": NSNull()
]

let batman = Character.fromJSONObject(batmanJSON,
        inContext: context, mergeChanges: true, error: &error)
```

### Back to JSON

```swift
let batmanJSON = batman.toJSONObject()
```

## Contact
[Guillermo Gonzalez](http://github.com/gonzalezreal)  
[@gonzalezreal](https://twitter.com/gonzalezreal)

## License
Groot is available under the MIT license. See [LICENSE](https://github.com/gonzalezreal/Groot/blob/master/LICENSE).
