//
//  CoreDataFeedStore.swift
//  EssentialFeed
//
//  Created by Denis Yaremenko on 30.01.2025.
//

import CoreData

public final class CoreDataFeedStore: FeedStore {
    private let container: NSPersistentContainer
    private let context: NSManagedObjectContext
    
    public init(storeURL: URL, bundle: Bundle = .main) throws {
        container = try NSPersistentContainer.load(modelName: "FeedStore", url: storeURL, in: bundle)
        context = container.newBackgroundContext()
    }
    
    public func retrieve(completion: @escaping RetrievalCompletion) {
        perform { context in
            /// #option 1
            //            do {
            //                if let cache = try ManagedCache.find(in: context) {
            //                    completion(.success(.some(CachedFeed(feed: cache.localFeed, timestamp: cache.timestamp))))
            //                } else {
            //                    completion(.success(.none))
            //                }
            //            } catch {
            //                completion(.failure(error))
            //            }
            
            /// #option 2
            completion(Result {
                try ManagedCache.find(in: context).map {
                    return CachedFeed(feed: $0.localFeed, timestamp: $0.timestamp)
                }
            })
        }
    }
    
    public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        perform { context in
            
            /// #option 1
            //            do {
            //                let managedCache = try ManagedCache.newUniqueInstance(in: context)
            //                managedCache.timestamp = timestamp
            //                managedCache.feed = ManagedFeedImage.images(from: feed, in: context)
            //
            //                try context.save()
            //                completion(nil)
            //            } catch {
            //                completion(error)
            //            }
            
            /// #option 2
            completion(Result {
                let managedCache = try ManagedCache.newUniqueInstance(in: context)
                managedCache.timestamp = timestamp
                managedCache.feed = ManagedFeedImage.images(from: feed, in: context)
                try context.save()
            })
        }
    }
    
    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        perform { context in
            /// #option 1
            //            do {
            //                try ManagedCache.find(in: context).map(context.delete).map(context.save)
            //                completion(nil)
            //            } catch {
            //                completion(error)
            //            }
            
            /// #option 2
            completion(Result {
                try ManagedCache.find(in: context).map(context.delete).map(context.save)
            })
        }
    }
    
    /// Обеспечивает безопасность потоков, так как NSManagedObjectContext нельзя использовать в другом потоке напрямую
    ///  Избегает блокировок основного потока, так как все операции выполняются в фоновом контексте
    private func perform(_ action: @escaping (NSManagedObjectContext) -> Void) {
        let context = self.context
        context.perform { action(context) }
    }
}
