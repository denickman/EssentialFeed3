//
//  FeedImageDataStore.swift
//  EssentialFeed
//
//  Created by Denis Yaremenko on 13.02.2025.
//

import Foundation

/// FeedImageDataStore is an abstraction to hide infrastructure details (e.g. coredata) from its client (LocalFeedImageDataLoader)

public protocol FeedImageDataStore {
    typealias RetrievalResult = Swift.Result<Data?, Error>
    typealias InsertionResult = Swift.Result<Void, Error>

    func insert(_ data: Data, for url: URL, completion: @escaping (InsertionResult) -> Void)
    func retrieve(dataForURL url: URL, completion: @escaping (RetrievalResult) -> Void)
}
