//
//  FeedLoaderCacheDecoratorTests.swift
//  EssentialAppTests
//
//  Created by Denis Yaremenko on 15.02.2025.
//

import XCTest
import EssentialFeed
import EssentialApp

final class FeedLoaderCacheDecoratorTests: XCTestCase, FeedLoaderTestCase {
    
    func test_load_deliversFeedOnLoaderSuccess() {
        let feed = uniqueFeed()
        let sut = makeSUT(loaderResult: .success(feed))
        
        expect(sut, toCompleteWith: .success(feed))
    }
    
    func test_load_deliversErrorOnLoaderFailure() {
        let sut = makeSUT(loaderResult: .failure(anyNSError()))
        
        expect(sut, toCompleteWith: .failure(anyNSError()))
    }
    
    // mutation side effect (saving operation)
    func test_load_cachesLoadedFeedOnLoaderSuccess() {
        let cacheSpy = CacheSpy()
        let feed = uniqueFeed()
        let sut = makeSUT(loaderResult: .success(feed), cache: cacheSpy)
        sut.load() { _ in }
        
        XCTAssertEqual(cacheSpy.messages, [.save(feed)], "Expected to cache load feed on success")
    }
    
    func test_load_doesNotCacheOnLoaderFailure() {
        let cacheSpy = CacheSpy()
        let sut = makeSUT(loaderResult: .failure(anyNSError()), cache: cacheSpy)
        sut.load() { _ in }
        
        XCTAssertEqual(cacheSpy.messages, [], "Expected not to cache on load error")
    }
    
    // MARK: - Helpers
    
    private func makeSUT(
        loaderResult: FeedLoader.Result,
        cache: CacheSpy = .init(),
        file: StaticString = #file,
        line: UInt = #line
    ) -> FeedLoader {
        let loader = FeedLoaderStub(result: loaderResult)
        let sut = FeedLoaderCacheDecorator(decoratee: loader, cache: cache)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private class CacheSpy: FeedCache {
        
        enum Message: Equatable {
            case save([FeedImage])
        }
        
        private(set) var messages = [Message]()

        func save(_ feed: [FeedImage], completion: @escaping (FeedCache.Result) -> Void) {
            messages.append(.save(feed))
            completion(.success(()))
        }
    }
}
