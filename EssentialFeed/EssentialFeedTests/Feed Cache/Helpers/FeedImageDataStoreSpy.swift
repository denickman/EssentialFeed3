//
//  FeedImageDataStoreSpy.swift
//  EssentialFeedTests
//
//  Created by Denis Yaremenko on 13.02.2025.
//

import Foundation
import EssentialFeed

class FeedImageDataStoreSpy: FeedImageDataStore {
    
    enum Message: Equatable {
        case insert(data: Data, for: URL)
        case retrieve(dataFor: URL)
    }

    private(set) var receivedMessages = [Message]()
    
    // for ASync API
    private var retrievalCompletions = [(FeedImageDataStore.RetrievalResult) -> Void]()
    private var insertionCompletions = [(FeedImageDataStore.InsertionResult) -> Void]()
    
    // for Sync API
    private var insertionResult: Result<Void, Error>?
    private var retrievalResult: Result<Data?, Error>?

    // ASync API
    func insert(_ data: Data, for url: URL, completion: @escaping (FeedImageDataStore.InsertionResult) -> Void) {
        receivedMessages.append(.insert(data: data, for: url))
        insertionCompletions.append(completion)
    }

    func retrieve(dataForURL url: URL, completion: @escaping (FeedImageDataStore.RetrievalResult) -> Void) {
        receivedMessages.append(.retrieve(dataFor: url))
        retrievalCompletions.append(completion)
    }

    func completeRetrieval(with data: Data?, at index: Int = 0) {
//        retrievalCompletions[index](.success(data)) // ASync API
        retrievalResult = .success(data)
    }
    
    func completeRetrieval(with error: Error, at index: Int = 0) {
//        retrievalCompletions[index](.failure(error)) // ASync API
        retrievalResult = .failure(error)
    }

    func completeInsertionSuccessfully(at index: Int = 0) {
        // insertionCompletions[index](.success(())) // ASync API
        insertionResult = .success(()) // Sync API
    }
    
    func completeInsertion(with error: Error, at index: Int = 0) {
       // insertionCompletions[index](.failure(error))  // ASync API
        insertionResult = .failure(error) // Sync API
    }
    
    // Sync API
    func insert(_ data: Data, for url: URL) throws {
        receivedMessages.append(.insert(data: data, for: url))
        try insertionResult?.get()
    }
    
    func retrieve(dataForURL url: URL) throws -> Data? {
        receivedMessages.append(.retrieve(dataFor: url))
        return try retrievalResult?.get()
    }
}
