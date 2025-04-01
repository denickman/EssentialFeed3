//
//  CoreDataFeedStore.swift
//  EssentialFeed
//
//  Created by Denis Yaremenko on 30.01.2025.
//

import CoreData

public final class CoreDataFeedStore {
    private static let modelName = "FeedStore"
    private static let model = NSManagedObjectModel.with(name: modelName, in: Bundle(for: CoreDataFeedStore.self))
    
    private let container: NSPersistentContainer
    private let context: NSManagedObjectContext

    enum StoreError: Error {
        case modelNotFound
        case failedToLoadPersistentContainer(Error)
    }

    public init(storeURL: URL) throws {
        guard let model = CoreDataFeedStore.model else {
            throw StoreError.modelNotFound
        }
        
        do {
            container = try NSPersistentContainer.load(name: CoreDataFeedStore.modelName, model: model, url: storeURL)
            context = container.newBackgroundContext()
        } catch {
            throw StoreError.failedToLoadPersistentContainer(error)
        }
    }
    
    // For Sync API
    func performSync<R>(_ action: (NSManagedObjectContext) -> Result<R, Error>) throws -> R {
        let context = self.context
        var result: Result<R, Error>!
        
        context.performAndWait { result = action(context) } // синхронный код
        return try result.get()
    }
    
    // For ASync API
    func performAsync(_ action: @escaping (NSManagedObjectContext) -> Void) {
        /// Обеспечивает безопасность потоков, так как NSManagedObjectContext нельзя использовать в другом потоке напрямую
        ///  Избегает блокировок основного потока, так как все операции выполняются в фоновом контексте
        /// Этот метод выполняет переданный блок асинхронно, т.е. код будет выполняться в контексте соответствующей очереди (например, в фоне, если это фоновой контекст). Это аналог асинхронного вызова, потому что блок будет выполнен в фоновом потоке, а выполнение метода продолжится сразу, не дожидаясь завершения операции.
        let context = self.context
        context.perform { action(context) }
    }
  
    private func cleanUpReferencesToPersistentStores() {
        context.performAndWait {
            let coordinator = self.container.persistentStoreCoordinator
            try? coordinator.persistentStores.forEach(coordinator.remove)
        }
    }
    
    deinit {
        cleanUpReferencesToPersistentStores()
    }
}


/*
public final class CoreDataFeedStore {
    
    enum StoreError: Error {
             case modelNotFound
             case failedToLoadPersistentContainer(Error)
         }
    
     private static let modelName = "FeedStore"
     private static let model = NSManagedObjectModel.with(name: modelName, in: Bundle(for: CoreDataFeedStore.self))
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

    private func perform(_ action: @escaping (NSManagedObjectContext) -> Void) {
        let context = self.context
        context.perform { action(context) }
    }
}
*/
