//
//  FeedImageDataStore.swift
//  EssentialFeed
//
//  Created by Denis Yaremenko on 13.02.2025.
//

import Foundation

/// FeedImageDataStore is an abstraction to hide infrastructure details (e.g. coredata) from its client (LocalFeedImageDataLoader)

public protocol FeedImageDataStore {
   // Async API
    
//    typealias RetrievalResult = Swift.Result<Data?, Error>
//    typealias InsertionResult = Swift.Result<Void, Error>
//    
//    @available(*, deprecated)
//    func insert(_ data: Data, for url: URL, completion: @escaping (InsertionResult) -> Void)
//    
//    @available(*, deprecated)
//    func retrieve(dataForURL url: URL, completion: @escaping (RetrievalResult) -> Void)
    
    // Sync API
    func insert(_ data: Data, for url: URL) throws
    func retrieve(dataForURL url: URL) throws -> Data?
}


// temporary extension to not break clients since moving from async to Sync API
/*
public extension FeedImageDataStore {
    
    func insert(_ data: Data, for url: URL) throws {
        // возвращается Void (ничего), поэтому return try result.get() просто завершает выполнение или выбрасывает ошибку
        let group = DispatchGroup()
        
        group.enter()
        var result: InsertionResult!
        
        insert(data, for: url) {
            result = $0
            group.leave()
        }
        
        group.wait()
        return try result.get() // чтобы обработать возможную ошибку и завершить выполнение, так как метод ничего не возвращает
    }
    
    func retrieve(dataForURL url: URL) throws -> Data? {
        let group = DispatchGroup()
        group.enter()
        
        var result: RetrievalResult!
    
        retrieve(dataForURL: url, completion: {
            result = $0 // Result<Data?, Error>
            group.leave()
        })
        
        group.wait()
        return try result.get()
    }
 

    func insert(_ data: Data, for url: URL, completion: @escaping (InsertionResult) -> Void) {
        
    }
    
    func retrieve(dataForURL url: URL, completion: @escaping (RetrievalResult) -> Void) {
        
    }
}
*/
