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
    
    // for async api
    private var retrievalCompletions = [(FeedImageDataStore.RetrievalResult) -> Void]()
    private var insertionCompletions = [(FeedImageDataStore.InsertionResult) -> Void]()
    
    // for sync api
    private var insertionResult: Result<Void, Error>?

    // async api
    func insert(_ data: Data, for url: URL, completion: @escaping (FeedImageDataStore.InsertionResult) -> Void) {
        receivedMessages.append(.insert(data: data, for: url))
        insertionCompletions.append(completion)
    }

    func retrieve(dataForURL url: URL, completion: @escaping (FeedImageDataStore.RetrievalResult) -> Void) {
        receivedMessages.append(.retrieve(dataFor: url))
        retrievalCompletions.append(completion)
    }

    func completeRetrieval(with data: Data?, at index: Int = 0) {
        retrievalCompletions[index](.success(data))
    }
    
    func completeRetrieval(with error: Error, at index: Int = 0) {
        retrievalCompletions[index](.failure(error))
    }

    func completeInsertionSuccessfully(at index: Int = 0) {
        // insertionCompletions[index](.success(())) // async api
        insertionResult = .success(()) // sync api
    }
    
    func completeInsertion(with error: Error, at index: Int = 0) {
       // insertionCompletions[index](.failure(error))  // async api
        insertionResult = .failure(error) // sync api
    }
    
    // sync api
    func insert(_ data: Data, for url: URL) throws {
        receivedMessages.append(.insert(data: data, for: url))
        try insertionResult?.get()
    }
}
