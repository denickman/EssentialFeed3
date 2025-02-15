//
//  FeedLoaderCacheDecorator.swift
//  EssentialApp
//
//  Created by Denis Yaremenko on 15.02.2025.
//

import Foundation
import EssentialFeediOS
import EssentialFeed

public final class FeedLoaderCacheDecorator: FeedLoader {
    
    private let decoratee: FeedLoader
    private let cache: FeedCache
    
    public init(decoratee: FeedLoader, cache: FeedCache) {
        self.decoratee = decoratee
        self.cache = cache
    }
    
    public func load(completion: @escaping (FeedLoader.Result) -> Void) {
        decoratee.load { [weak self] result in
            /// #option 1
            /*
             // option 1.1
            if let feed = try? result.get() {
                self?.cache.save(feed, completion: { result in
                    
                })
            }
             
             // option 1.2
             if case let .success(feed) = result {
                 self?.cache.save(feed) { _ in }
             }
             
            completion(result)
            */
            
            /// #option 1
            completion(result.map { feed in
                self?.cache.saveIgnoringResult(feed) // ignoring the result in that case
                return feed
            })
            
        }
    }
}

// to clarify our intend we want to ignore the result
private extension FeedCache {
    func saveIgnoringResult(_ feed: [FeedImage]) {
        save(feed) { _ in }
    }
}
