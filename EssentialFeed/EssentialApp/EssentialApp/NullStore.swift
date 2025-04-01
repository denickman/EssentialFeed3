//
//  NullStore.swift
//  EssentialApp
//
//  Created by Denis Yaremenko on 28.03.2025.
//

import Foundation
import EssentialFeed

// For neutral behaviour

class NullStore: FeedStore & FeedImageDataStore {
    
    func insert(_ data: Data, for url: URL) throws {
        // do not do anything, provide a neutral implementation
    }
    
    func retrieve(dataForURL url: URL) throws -> Data? {
        .none
    }

    func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        completion(.success(()))
    }
    
    func insert(_ feed: [EssentialFeed.LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        completion(.success(()))
    }
    
    func retrieve(completion: @escaping RetrievalCompletion) {
        completion(.success(.none))
    }
    
    // Async API
//    func insert(_ data: Data, for url: URL, completion: @escaping (InsertionResult) -> Void) {
//        completion(.success(()))
//    }
//    
//    func retrieve(dataForURL url: URL, completion: @escaping (FeedImageDataStore.RetrievalResult) -> Void) {
//        completion(.success(.none))
//    }
}


