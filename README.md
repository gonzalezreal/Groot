# Groot
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage) ![CocoaPods compatible](https://img.shields.io/cocoapods/v/Groot.svg)

Groot provides a simple way of serializing Core Data object graphs from or into JSON.

Groot uses the [annotations](#annotating-your-model) defined in the Core Data model to perform the serialization and provides the following features:

1. Attribute and relationship mapping to JSON key paths.
2. [Value transformation](#value-transformers) using named `NSValueTransformer` objects.
3. [Automatic merging](#automatic-merging)
4. Support for [Entity inheritance](#entity-inheritance-support)

## Installing Groot

##### Using CocoaPods

Add the following to your `Podfile`:

``` ruby
pod ‘Groot’
```

Or, if you need to support iOS 6 / OS X 10.8:

``` ruby
pod ‘Groot/ObjC’
```

Then run `$ pod install`.

If you don’t have CocoaPods installed or integrated into your project, you can learn how to do so [here](http://cocoapods.org).

##### Using Carthage

Add the following to your `Cartfile`:

```
github “gonzalezreal/Groot”
```

Then run `$ carthage update`.

Follow the instructions in [Carthage’s README](https://github.com/Carthage/Carthage#adding-frameworks-to-an-application]) to add the framework to your project.

You may need to set **Embedded Content Contains Swift Code** to **YES** in the build settings for targets that only contain Objective-C code.

## Annotating your model

An exhaustive list of user info keys and values.
Reassure the reader that it works both ways.
How to ignore a property.

## Value transformers

## Serializing from JSON

## Automatic merging

## Entity inheritance

## Serializing to JSON

## Contact

[Guillermo Gonzalez](http://github.com/gonzalezreal)  
[@gonzalezreal](https://twitter.com/gonzalezreal)

## License

Groot is available under the [MIT license](LICENSE.md).