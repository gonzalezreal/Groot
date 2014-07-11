# Groot
With Groot you can convert JSON dictionaries and arrays to and from Core Data managed objects.

## Requirements
Groot supports OS X 10.8+ and iOS 6.0+.

## Installation
Add the following to your `Podfile` and run `$ pod install`.

``` ruby
pod 'Groot'
```

If you don't have CocoaPods installed or integrated into your project, you can learn how to do so [here](http://cocoapods.org).

## Usage
Consider the following Core Data model for a superhero database:

![Model](https://raw.githubusercontent.com/gonzalezreal/Groot/master/Images/sample-model.jpg)

Using Groot we could insert JSON data with a simple method call:

```objc
NSDictionary *batmanJSON = @{
	@"id": @1699,
	@"name": @"Batman",
	@"real_name": @"Bruce Wayne",
	@"powers": @[
	@{
		@"id": @4,
		@"name": @"Agility"
	},
	@{
		@"id": @9,
		@"name": @"Insanely Rich"
	}],
	@"publisher": @{
		@"id": @10,
		@"name": @"DC Comics"
	}
};

NSError *error = nil;
NSManagedObject *batman = [GRTJSONSerialization insertObjectForEntityName:@"Character"
													   fromJSONDictionary:batmanJSON
												   inManagedObjectContext:context
														            error:&error];
```

The serialization process can be customized by adding certain information to the user dictionary available for Core Data *entities*, *attributes* and *relationships*.

You can specify how an attribute or a relationship is mapped to JSON using the `JSONKeyPath` option. If this option is not present, then the attribute name will be used. If `JSONKeyPath` is associated with the string `null`, then the attribute or relationship will not participate in JSON serialization.

![Property User Info](https://raw.githubusercontent.com/gonzalezreal/Groot/master/Images/property-userInfo.jpg)

### Merge

Groot provides methods to merge (that is, create or update) managed objects from JSON representations. To use the merge methods, you need to specify an identity attribute on each *entity*, using the `identityAttribute` option.

![Entity User Info](https://raw.githubusercontent.com/gonzalezreal/Groot/master/Images/entity-userInfo.jpg)

```objc
NSDictionary *updateJSON = @{
	@"id": @1699,
	@"real_name": @"Guille Gonzalez"
}

// This will return the previously created managed object
NSManagedObject *batman = [GRTJSONSerialization mergeObjectForEntityName:@"Character"
													  fromJSONDictionary:batmanJSON
												  inManagedObjectContext:context
														           error:NULL];
```

### Convert a NSManagedObject into a JSON representation

You can convert managed objects into its JSON representation by using `JSONDictionaryFromManagedObject:` or `JSONArrayFromManagedObjects:`.

```objc
NSDictionary *JSONDictionary = [GRTJSONSerialization JSONDictionaryFromManagedObject:someManagedObject];
```

## Contact
[Guillermo Gonzalez](http://github.com/gonzalezreal)  
[@gonzalezreal](https://twitter.com/gonzalezreal)

## License
Overcoat is available under the MIT license. See [LICENSE](https://github.com/gonzalezreal/Groot/blob/master/LICENSE).
