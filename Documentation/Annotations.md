# Annotations

Entities, attributes and relationships in a managed object model have an associated **user info dictionary** in which you can specify custom metadata as key-value pairs.

Groot relies on the presence of certain key-value pairs in the user info dictionary associated with entities, attributes and relationships to serialize managed objects from or into JSON. These key-value pairs are often referred in the documentation as **annotations**.

You can use the **Data Model inspector** in Xcode to annotate entities, attributes and relationships:

<img src="https://cloud.githubusercontent.com/assets/373190/6988412/78b00006-da51-11e4-908a-de40c99141e8.png" alt="Data Model inspector" width=260 height=338/>

This document lists all the different keys you can use to annotate models, and the purpose of each.

## Property annotations

### `JSONKeyPath`

Using this key you can specify how your managed object’s properties (that is, attributes and relationships) map to key paths in a JSON object.

For example, consider this JSON modelling a famous comic book character:

```json
{
    "id": "1699",
    "name": "Batman",
    "publisher": {
        "id": "10",
        "name": "DC Comics"
    }
}
```

We could model this in Core Data using two related entities: `Character` and `Publisher`.

The `Character` entity could have `identifier` and `name` attributes, and a `publisher` to-one relationship.

The `Publisher` entity could have `identifier` and `name` attributes, and a `characters` to-many relationship.

Each of these properties should have a `JSONKeyPath` entry in their corresponding user info dictionary:

* `id` for the `identifier` attribute,
* `name` for the `name` attribute,
* `publisher` for the `publisher` relationship,
* etc.

Attributes and relationships that don't have a `JSONKeyPath` entry are **not considered** for JSON serialization or deserialization.

Note that if we were only interested in the publisher's name, we could drop the `Publisher` entity and add a `publisherName` attribute specifying `publisher.name` as the `JSONKeyPath`.

### `JSONTransformerName`

With this key you can specify the name of a value transformer that will be used to transform values when serializing from or into JSON.

Consider the `id` key in the previous JSON. Some web APIs send 64-bit integers as strings to support languages that have trouble consuming large integers.

We should store identifier values as integers instead of strings to save space.

First we need to change the `identifier` attribute's type to `Integer 64` in both the `Character` and `Publisher` entities.

Then we add a `JSONTransformerName` entry to each `identifier` attribute's user info dictionary with the name of the value transformer: `StringToInteger`.

Finally we create the value transformer and give it the name we just used:

```objc
[NSValueTransformer grt_setValueTransformerWithName:@"StringToInteger" transformBlock:^id(NSString *value) {
    return @([value integerValue]);
} reverseTransformBlock:^id(NSNumber *value) {
    return [value stringValue];
}];
```

If we were not interested in serializing characters back into JSON we could omit the reverse transformation:

```objc
[NSValueTransformer grt_setValueTransformerWithName:@"StringToInteger" transformBlock:^id(NSString *value) {
    return @([value integerValue]);
}];
```

## Entity annotations

### `identityAttributes`

Use this key to specify one or more attributes that uniquely identify instances of an entity.

In our example, we should add an `identityAttributes` entry to both the `Character` and `Publisher` entities user dictionaries with the value `identifier`.

Multiple attributes must be separated by comma. For instance, suppose that we have an entity representing a card in a deck: We could set the value of the `identityAttributes` key to `suit, value`.

Note that sub-entities implicitly extend their parent `identityAttributes`. For example, if you specify `UUID` as the `identityAttributes` for a parent entity and `email` for its sub-entity, Groot will use `UUID, email` to uniquely identify instances of the sub-entity.

Specifying the `identityAttributes` for an entity is essential to preserve the object graph and avoid duplicate information when serializing from JSON.

### `entityMapperName`

If your model uses entity inheritance, use this key in the base entity to specify an entity mapper name.

An entity mapper is used to determine which sub-entity is used when deserializing an object from JSON.

For example, consider the following JSON:

```json
{
	"messages": [
		{
			"id": 1,
			"type": "text",
			"text": "Hello there!"
		},
		{
			"id": 2,
			"type": "picture",
			"image_url": "http://example.com/risitas.jpg"
		}
	]
}
```

We could model this in Core Data using an abstract base entity `Message` and two concrete sub-entities `TextMessage` and `PictureMessage`.

Then we need to add an `entityMapperName` entry to the `Message` entity's user info dictionary: `MessageMapper`.

Finally we create the entity mapper and give it the name we just used:

```objc
[NSValueTransformer grt_setEntityMapperWithName:@"MessageMapper" mapBlock:^NSString *(NSDictionary *JSONDictionary) {
    NSDictionary *entityMapping = @{
        @"text": @"TextMessage",
        @"picture": @"PictureMessage"
    };
    NSString *type = JSONDictionary[@"type"];
    return entityMapping[type];
}];
```

### `JSONDictionaryTransformerName`

This is an optional key you can specify at entity level that contains the name of a value transformer that will be used to transform the JSON dictionaries before serializing them to the target entity.

Think about it as an optional preprocessing step for your JSON.

Consider the situation in which we need to support both legacy and current JSON specs for one of the entities in the model. We could add a `JSONDictionaryTransformerName` entry and create the corresponding dictionary transformer:

```objc
[NSValueTransformer grt_setDictionaryTransformerWithName:@“MyTransformer”
										  transformBlock:^NSDictionary *(NSDictionary *JSONDictionary) {
											  id legacyIdentifier = JSONDictionary[@“legacy_id”];
											  if (legacyIdentifier != nil) {
												  NSMutableDictionary *dictionary = [JSONDictionary mutableCopy];
												  dictionary[@“id”] = legacyIdentifier;
												  
												  return dictionary;
											  }
											  
											  return JSONDictionary;
										  }];
```

This will ‘upgrade’ our legacy JSON objects to the new version which is the one that correctly maps to our entity.
