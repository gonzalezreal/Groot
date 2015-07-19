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

We can declare the `identifier` attribute in both the `Character` and `Publisher` entities as a 64-bit integer to save some storage space.

Then we can add a `JSONTransformerName` entry to the attribute's user info dictionary with the name of the value transformer: `StringToInteger`.

Finally we can create the value transformer and give it the name we just used:

```objc
[NSValueTransformer grt_setValueTransformerWithName:@"StringToInteger" transformBlock:^id(NSString *value) {
    return @([value integerValue]);
} reverseTransformBlock:^id(NSNumber *value) {
    return [value stringValue];
}];
```

If you don't need to serialize managed objects back into JSON, you don't need to specify a reverse transformation:

```objc
[NSValueTransformer grt_setValueTransformerWithName:@"StringToInteger" transformBlock:^id(NSString *value) {
    return @([value integerValue]);
}];
```

## Entity annotations

### `identityAttribute`

### `entityMapperName`
