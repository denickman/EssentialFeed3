//
//  CoreDataFeedStore+FeedImageDataLoader.swift
//  EssentialFeed
//
//  Created by Denis Yaremenko on 13.02.2025.
//

import Foundation

extension CoreDataFeedStore: FeedImageDataStore {
    
    // for Sync API
    public func insert(_ data: Data, for url: URL) throws { // если произойдёт ошибка, она будет выброшена,
         try performSync { context in
            Result {
                try ManagedFeedImage.first(with: url, in: context) // return managedFeedImage
                    .map { $0.data = data } // managedFeedImage.data
                    .map(context.save) // Если операция прошла успешно
            }
        }
    }
    
    public func retrieve(dataForURL url: URL) throws -> Data? {
        try performSync { context in
            Result {
                try ManagedFeedImage.data(with: url, in: context)
            }
        }
    }
    
    // for Async API
    public func insert(_ data: Data, for url: URL, completion: @escaping (FeedImageDataStore.InsertionResult) -> Void) {
        performAsync { context in
            completion(Result {
                try ManagedFeedImage.first(with: url, in: context)
                    .map { $0.data = data }
                    .map(context.save)
            })
        }
    }

    public func retrieve(dataForURL url: URL, completion: @escaping (FeedImageDataStore.RetrievalResult) -> Void) {
        performAsync { context in
            completion(Result {
                try ManagedFeedImage.data(with: url, in: context)
            })
        }
    }

}
