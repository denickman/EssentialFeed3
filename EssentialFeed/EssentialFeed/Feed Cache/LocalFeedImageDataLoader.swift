//
//  LocalFeedImageDataLoader.swift
//  EssentialFeed
//
//  Created by Denis Yaremenko on 13.02.2025.
//

import Foundation

public final class LocalFeedImageDataLoader {
    
    private let store: FeedImageDataStore
    
    public init(store: FeedImageDataStore) {
        self.store = store
    }
}

extension LocalFeedImageDataLoader: FeedImageDataCache {
    
    // public typealias SaveResult = Result<Void, Error> // for Async API
    
    public enum SaveError: Error {
        case failed
    }
    
    // for Sync API
    public func save(_ data: Data, for url: URL) throws {
        do {
            try store.insert(data, for: url)
        } catch {
            throw SaveError.failed
        }
    }
    
    // for Async API
    //    public func save(_ data: Data, for url: URL, completion: @escaping (SaveResult) -> Void) {
    //        store.insert(data, for: url) { [weak self] result in
    //            guard self != nil else { return }
    //            completion(result.mapError { _ in SaveError.failed })
    //        }
    //    }
}

extension LocalFeedImageDataLoader: FeedImageDataLoader {
    
    public enum LoadError: Error {
        case failed
        case notFound
    }
    // Async API
    //    private final class LoadImageDataTask: FeedImageDataLoaderTask {
    //        private var completion: ((FeedImageDataLoader.Result) -> Void)?
    //
    //        init(_ completion: @escaping (FeedImageDataLoader.Result) -> Void) {
    //            self.completion = completion
    //        }
    //
    //        func complete(with result: FeedImageDataLoader.Result) {
    //            completion?(result)
    //        }
    //
    //        func cancel() {
    //            preventFurtherCompletions()
    //        }
    //
    //        private func preventFurtherCompletions() {
    //            completion = nil
    //        }
    //    }
    
    public func loadImageData(from url: URL) throws -> Data {
        do {
            if let imageData = try store.retrieve(dataForURL: url) {
                return imageData
            }
        } catch {
            throw LoadError.failed
        }
        
        throw LoadError.notFound
    }
    
    // for Async API
    //    public func loadImageData(from url: URL, completion: @escaping (LoadResult) -> Void) -> FeedImageDataLoaderTask {
    //        let task = LoadImageDataTask(completion)
    //        store.retrieve(dataForURL: url) { [weak self] result in
    //            guard self != nil else { return }
    //
    //            task.complete(with: result
    //                .mapError { _ in LoadError.failed }
    //                .flatMap { data in
    //                    data.map { .success($0) } ?? .failure(LoadError.notFound)
    //                })
    //        }
    //        return task
    //    }
}
