//
//  FeedLoaderStub.swift
//  EssentialAppTests
//
//  Created by Denis Yaremenko on 15.02.2025.
//

import EssentialFeed

class LoaderStub: FeedLoader {
    
    private let result: FeedLoader.Result

    init(result: FeedLoader.Result) {
        self.result = result
    }

    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        completion(result)
    }
}
