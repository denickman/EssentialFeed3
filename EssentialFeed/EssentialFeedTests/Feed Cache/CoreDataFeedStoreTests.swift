//
//  CoreDataFeedStoreTests.swift
//  EssentialFeed
//
//  Created by Denis Yaremenko on 30.01.2025.
//

import XCTest
import EssentialFeed

class CoreDataFeedStoreTests: XCTestCase, FeedStoreSpecs {
    
    func test_retrieve_deliversEmptyOnEmptyCache() throws {
        try makeSUT { sut in
            self.assertThatRetrieveDeliversEmptyOnEmptyCache(on: sut)
        }
    }
    
    func test_retrieve_hasNoSideEffectsOnEmptyCache() throws {
        try makeSUT { sut in
            self.assertThatRetrieveHasNoSideEffectsOnEmptyCache(on: sut)
        }
    }
    
    func test_retrieve_deliversFoundValuesOnNonEmptyCache() throws {
        try makeSUT { sut in
            self.assertThatRetrieveDeliversFoundValuesOnNonEmptyCache(on: sut)
        }
    }
    
    func test_retrieve_hasNoSideEffectsOnNonEmptyCache() throws {
        try makeSUT { sut in
            self.assertThatRetrieveHasNoSideEffectsOnNonEmptyCache(on: sut)
        }
    }
    
    func test_insert_deliversNoErrorOnEmptyCache() throws {
        try makeSUT { sut in
            self.assertThatInsertDeliversNoErrorOnEmptyCache(on: sut)
        }
    }
    
    func test_insert_deliversNoErrorOnNonEmptyCache() throws {
        try makeSUT { sut in
            self.assertThatInsertDeliversNoErrorOnNonEmptyCache(on: sut)
        }
    }
    
    func test_insert_overridesPreviouslyInsertedCacheValues() throws {
        try makeSUT { sut in
            self.assertThatInsertOverridesPreviouslyInsertedCacheValues(on: sut)
        }
    }
    
    func test_delete_deliversNoErrorOnEmptyCache() throws {
        try makeSUT { sut in
            self.assertThatDeleteDeliversNoErrorOnEmptyCache(on: sut)
        }
    }
    
    func test_delete_hasNoSideEffectsOnEmptyCache() throws {
        try makeSUT { sut in
            self.assertThatDeleteHasNoSideEffectsOnEmptyCache(on: sut)
        }
    }
    
    func test_delete_deliversNoErrorOnNonEmptyCache() throws {
        try makeSUT { sut in
            self.assertThatDeleteDeliversNoErrorOnNonEmptyCache(on: sut)
        }
    }
    
    func test_delete_emptiesPreviouslyInsertedCache() throws {
        try makeSUT { sut in
            self.assertThatDeleteEmptiesPreviouslyInsertedCache(on: sut)
        }
    }
    
    func test_storeSideEffects_runSerially() throws {
        try makeSUT { sut in
            self.assertThatSideEffectsRunSerially(on: sut)
        }
    }
    
    // - MARK: Helpers
    
    private func makeSUT(
        _ test: @escaping (CoreDataFeedStore) -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) throws {
        let storeURL = URL(fileURLWithPath: "/dev/null")
        let sut = try! CoreDataFeedStore(storeURL: storeURL)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        let exp = expectation(description: "Wait for operation")
        
        sut.perform {
            test(sut)
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 0.1)
    }
}
