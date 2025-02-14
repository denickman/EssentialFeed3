//
//  FeedLoaderWithFallbackCompositeTests.swift
//  EssentialAppTests
//
//  Created by Denis Yaremenko on 14.02.2025.
//

import XCTest
import EssentialFeed

class FeedLoaderWithFallbackComposite: FeedLoader {
    
    private let primary: FeedLoader
    private let fallback: FeedLoader
    
    init(primary: FeedLoader, fallback: FeedLoader) {
        self.primary = primary
        self.fallback = fallback
    }
    
    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        primary.load(completion: completion)
    }
}

// test loading form remote at first, then use cache

final class FeedLoaderWithFallbackCompositeTests: XCTestCase {
    
    func test_load_deliversPrimaryFeedOnPrimaryLoaderSuccess() {
        
        let primaryFeed = uniqueFeed()
        let fallbackFeed = uniqueFeed()
        
        let primaryLoader = LoaderStub(result: .success(primaryFeed))
        let fallbackLoader = LoaderStub(result: .success(fallbackFeed))
       
        let sut = FeedLoaderWithFallbackComposite(primary: primaryLoader, fallback: fallbackLoader)
        
        let exp = expectation(description: "Wait for load completion")
                
        sut.load { result in
            switch result {
            case let .success(receivedFeed):
                XCTAssertEqual(receivedFeed, primaryFeed)
                
            case .failure:
                XCTFail("Expected successful load feed result, got \(result) instead.")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1)
    }
    
    // MARK: - Helpers
    
    private func uniqueFeed() -> [FeedImage] {
        [.init(id: UUID(), description: "any", location: "any", url: URL(string: "http://any-url.com")!)]
    }
    
    private class LoaderStub: FeedLoader {
        private let result: FeedLoader.Result
        
        init(result: FeedLoader.Result) {
            self.result = result
        }
        
        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            completion(result)
        }
    }

}
