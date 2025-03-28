//
//  ManagedFeedImage.swift
//  EssentialFeed
//
//  Created by Denis Yaremenko on 30.01.2025.
//

import CoreData

@objc(ManagedFeedImage)
class ManagedFeedImage: NSManagedObject {
    @NSManaged var id: UUID
    @NSManaged var imageDescription: String?
    @NSManaged var location: String?
    @NSManaged var url: URL
    @NSManaged var data: Data?
    @NSManaged var cache: ManagedCache
}

extension ManagedFeedImage {
    
    static func data(with url: URL, in context: NSManagedObjectContext) throws -> Data? {
        if let data = context.userInfo[url] as? Data {
            print(">> Retrive from local cache \(data)")
            return data
        }
        print(">> Retrive from Fetch Request")
        return try first(with: url, in: context)?.data
    }
    
    static func first(with url: URL, in context: NSManagedObjectContext) throws -> ManagedFeedImage? {
        let request = NSFetchRequest<ManagedFeedImage>(entityName: entity().name!)
        request.predicate = NSPredicate(format: "%K = %@", argumentArray: [#keyPath(ManagedFeedImage.url), url])
        request.returnsObjectsAsFaults = false
        request.fetchLimit = 1
        return try context.fetch(request).first
    }
    
    static func images(from localFeed: [LocalFeedImage], in context: NSManagedObjectContext) -> NSOrderedSet {
        let images = NSOrderedSet(array: localFeed.map { local in
            let managed = ManagedFeedImage(context: context)
            managed.id = local.id
            managed.imageDescription = local.description
            managed.location = local.location
            managed.url = local.url
            print(">> Get from the local cache \(context.userInfo[local.url])")
            managed.data = context.userInfo[local.url] as? Data // new
            return managed
        })
        // after creating
        print(">> Delete local cache")
        context.userInfo.removeAllObjects()
        return images
    }
    
    var local: LocalFeedImage {
        return LocalFeedImage(id: id, description: imageDescription, location: location, url: url)
    }
    
    override func prepareForDeletion() {
        super.prepareForDeletion()
        // temporary store data in user info object
        print(">> Save to local cache")
        managedObjectContext?.userInfo[url] = data // NSMutableDictionary
    }
}
