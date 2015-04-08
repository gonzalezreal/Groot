//
//  ManagedStore.swift
//  Groot
//
//  Created by Guille Gonzalez on 28/03/15.
//  Copyright (c) 2015 Guille Gonzalez. All rights reserved.
//

import CoreData

public func cachesDirectoryURL(error outError: NSErrorPointer) -> NSURL? {
    struct Data {
        static var onceToken: dispatch_once_t = 0
        static var URL: NSURL? = nil
    }
    
    dispatch_once(&Data.onceToken) {
        let fileManager = NSFileManager.defaultManager()
        let rootURL = fileManager.URLForDirectory(
            .CachesDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: false, error: outError)
        
        if let rootURL = rootURL,
            bundleIdentifier = NSBundle(forClass: ManagedStore.self).bundleIdentifier
        {
            let cachesDirectoryURL = rootURL.URLByAppendingPathComponent(bundleIdentifier)
            let success = fileManager.createDirectoryAtURL(
                cachesDirectoryURL, withIntermediateDirectories: true, attributes: nil, error: outError)
            
            if success {
                Data.URL = cachesDirectoryURL
            }
        }
    }
    
    return Data.URL
}

/// Manages a Core Data stack.
public final class ManagedStore {
    
    /// The managed object model.
    public var managedObjectModel: NSManagedObjectModel {
        return persistentStoreCoordinator.managedObjectModel
    }
    
    /// The persistent store coordinator.
    public let persistentStoreCoordinator: NSPersistentStoreCoordinator
    
    /// The URL for this managed store.
    public var URL: NSURL? {
        let persistentStore = persistentStoreCoordinator.persistentStores[0] as! NSPersistentStore
        return persistentStore.URL
    }
    
    /**
     Creates a `ManagedStore` that will persist data in a temporary file.
    
     :param: error If a new store cannot be created, upon return contains an instance of NSError that
                   describes the problem.
    
     :return: The newly-created store or `nil` if an error occurs.
     */
    public class func temporaryStore(error outError: NSErrorPointer) -> ManagedStore? {
        return (NSManagedObjectModel.mergedModelFromBundles(nil)).flatMap {
            temporaryStoreWithModel($0, error: outError)
        }
    }
    
    /**
     Creates a `ManagedStore` that will persist data in a temporary file.
    
     :param: model The managed object model.
     :param: error If a new store cannot be created, upon return contains an instance of NSError that
                   describes the problem.
    
     :return: The newly-created store or `nil` if an error occurs.
     */
    public class func temporaryStoreWithModel(model: NSManagedObjectModel, error outError: NSErrorPointer) -> ManagedStore? {
        let path = NSTemporaryDirectory().stringByAppendingPathComponent(NSUUID().UUIDString)
        
        return (NSURL(fileURLWithPath: path)).flatMap {
            ManagedStore(URL: $0, model: model, error: outError)
        }
    }
    
    /**
     Creates a `ManagedStore` that will persist data in a discardable cache file.
    
     :param: cacheName The name of the cache file.
     :param: error If a new store cannot be created, upon return contains an instance of NSError that
                   describes the problem.
    
     :return: The newly-created store or `nil` if an error occurs.
     */
    public class func storeWithCacheName(cacheName: String, error outError: NSErrorPointer) -> ManagedStore? {
        return (NSManagedObjectModel.mergedModelFromBundles(nil)).flatMap {
            storeWithCacheName(cacheName, model: $0, error: outError)
        }
    }
    
    /**
     Creates a `ManagedStore` that will persist data in a discardable cache file.
    
     :param: cacheName The name of the cache file.
     :param: model The managed object model.
     :param: error If a new store cannot be created, upon return contains an instance of NSError that
                   describes the problem.
    
     :return: The newly-created store or `nil` if an error occurs.
     */
    public class func storeWithCacheName(cacheName: String, model: NSManagedObjectModel, error outError: NSErrorPointer) -> ManagedStore? {
        return (cachesDirectoryURL(error: outError)).flatMap {
            ManagedStore(URL: $0.URLByAppendingPathComponent(cacheName), model: model, error: outError)
        }
    }
    
    /**
     Creates a `ManagedStore` at a given location.
    
     :param: URL The file location of the store. If `nil` the persistent store will be created in memory.
     :param: model A managed object model.
     :param: error If a new store cannot be created, upon return contains an instance of NSError that
                   describes the problem.
    
     :return: The newly-created store or `nil` if an error occurs.
     */
    public init?(URL: NSURL?, model: NSManagedObjectModel, error outError: NSErrorPointer) {
        persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        
        let storeType = (URL != nil ? NSSQLiteStoreType : NSInMemoryStoreType)
        let options = [
            NSMigratePersistentStoresAutomaticallyOption: true,
            NSInferMappingModelAutomaticallyOption: true
        ]
        
        let persistentStore = persistentStoreCoordinator.addPersistentStoreWithType(
            storeType, configuration: nil, URL: URL, options: options, error: outError
        )
        
        if persistentStore == nil {
            return nil
        }
    }
    
    /**
     Creates a `ManagedStore` that will persist data in memory.
    
     :param: model The managed object model.
     :param: error If a new store cannot be created, upon return contains an instance of NSError that
                   describes the problem.
    
     :return: The newly-created store or `nil` if an error occurs.
     */
    public convenience init?(model: NSManagedObjectModel, error outError: NSErrorPointer) {
        self.init(URL: nil, model: model, error: outError)
    }
    
    /// Creates and returns a managed object context for this store.
    public func contextWithConcurrencyType(concurrencyType: NSManagedObjectContextConcurrencyType) -> NSManagedObjectContext {
        let context = NSManagedObjectContext(concurrencyType: concurrencyType)
        context.persistentStoreCoordinator = persistentStoreCoordinator
        
        return context
    }
}
