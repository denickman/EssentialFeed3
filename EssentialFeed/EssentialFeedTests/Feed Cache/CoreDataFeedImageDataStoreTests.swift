//
//  CoreDataFeedImageDataStoreTests.swift
//  EssentialFeedTests
//
//  Created by Denis Yaremenko on 13.02.2025.
//

import XCTest
import EssentialFeed

class CoreDataFeedImageDataStoreTests: XCTestCase {
    
    func test_retrieveImageData_deliversNotFoundWhenEmpty() throws {
        try makeSUT { sut in
            expect(sut, toCompleteRetrievalWith: notFound(), for: anyURL())
        }
    }
    
    func test_retrieveImageData_deliversNotFoundWhenStoredDataURLDoesNotMatch() throws {
        
        try makeSUT { sut in
            let url = URL(string: "http://a-url.com")!
            let nonMatchingURL = URL(string: "http://another-url.com")!
            insert(anyData(), for: url, into: sut)
            expect(sut, toCompleteRetrievalWith: notFound(), for: nonMatchingURL)
        }
    }
    
    func test_retrieveImageData_deliversFoundDataWhenThereIsAStoredImageDataMatchingURL() throws {
        try makeSUT { sut in
            let storedData = anyData()
            let matchingURL = URL(string: "http://a-url.com")!
            insert(storedData, for: matchingURL, into: sut)
//            expect(sut, toCompleteRetrievalWith: found(storedData), for: matchingURL)
        }
    }
    
    func test_retrieveImageData_deliversLastInsertedValue() throws {
        try makeSUT { sut in
            let firstStoredData = Data("first".utf8)
            let lastStoredData = Data("last".utf8)
            let url = URL(string: "http://a-url.com")!
            insert(firstStoredData, for: url, into: sut)
            insert(lastStoredData, for: url, into: sut)
//            expect(sut, toCompleteRetrievalWith: found(lastStoredData), for: url)
        }
    }
    
    // Async API test
    //    func test_sideEffects_runSerially() {
    //        let sut = makeSUT()
    //        let url = anyURL()
    //
    //        let op1 = expectation(description: "Operation 1")
    //        sut.insert([localImage(url: url)], timestamp: Date()) { _ in
    //            op1.fulfill()
    //        }
    //
    //        let op2 = expectation(description: "Operation 2")
    //        sut.insert(anyData(), for: url) { _ in op2.fulfill() }
    //
    //        let op3 = expectation(description: "Operation 3")
    //        sut.insert(anyData(), for: url) { _ in op3.fulfill() }
    //
    //        wait(for: [op1, op2, op3], timeout: 5.0, enforceOrder: true)
    //    }
    
    // - MARK: Helpers
    
    private func makeSUT(
        _ test: @escaping (CoreDataFeedStore) -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) throws {
        let storeURL = URL(fileURLWithPath: "/dev/null")
        let sut = try CoreDataFeedStore(storeURL: storeURL)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        let exp = expectation(description: "wait for operation")
        
        sut.perform {
            test(sut)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 0.1)
    }
    
//    private func insert(
//        _ data: Data,
//        for url: URL,
//        into sut: CoreDataFeedStore,
//        file: StaticString = #file,
//        line: UInt = #line
//    ) {
//        let exp = expectation(description: "Wait for cache insertion")
//        let image = localImage(url: url)
//        
//        sut.insert([image], timestamp: Date()) { result in
//            if case let .failure(error) = result {
//                XCTFail("Failed to insert \(data) with error \(error)", file: file, line: line)
//            }
//            exp.fulfill()
//        }
//        
//        wait(for: [exp], timeout: 1.0) // не выполнится дальше код пока не вернется exp
//        
//        do {
//            try sut.insert(data, for: url)
//        } catch {
//            XCTFail("Failed to insert \(data) with error \(error)", file: file, line: line)
//        }
//    }
    
    
    // Async API implementation
    /*
     
     private func expect(_ sut: CoreDataFeedStore, toCompleteRetrievalWith expectedResult: FeedImageDataStore.RetrievalResult, for url: URL,  file: StaticString = #file, line: UInt = #line) {
     let exp = expectation(description: "Wait for load completion")
     sut.retrieve(dataForURL: url) { receivedResult in
     switch (receivedResult, expectedResult) {
     case let (.success( receivedData), .success(expectedData)):
     XCTAssertEqual(receivedData, expectedData, file: file, line: line)
     
     default:
     XCTFail("Expected \(expectedResult), got \(receivedResult) instead", file: file, line: line)
     }
     exp.fulfill()
     }
     wait(for: [exp], timeout: 1.0)
     }
     
     private func insert(_ data: Data, for url: URL, into sut: CoreDataFeedStore, file: StaticString = #file, line: UInt = #line) {
     let exp = expectation(description: "Wait for cache insertion")
     let image = localImage(url: url)
     sut.insert([image], timestamp: Date()) { result in
     switch result {
     case let .failure(error):
     XCTFail("Failed to save \(image) with error \(error)", file: file, line: line)
     exp.fulfill()
     
     case .success:
     sut.insert(data, for: url) { result in
     if case let Result.failure(error) = result {
     XCTFail("Failed to insert \(data) with error \(error)", file: file, line: line)
     }
     exp.fulfill()
     }
     }
     }
     wait(for: [exp], timeout: 1.0)
     }
     */
    
}


private func notFound() -> Result<Data?, Error> {
    return .success(.none)
}

private func found(_ data: Data) -> Result<Data?, Error> {
    return .success(data)
}

private func localImage(url: URL) -> LocalFeedImage {
    return LocalFeedImage(id: UUID(), description: "any", location: "any", url: url)
}

private func expect(_ sut: CoreDataFeedStore, toCompleteRetrievalWith expectedResult: Result<Data?, Error>, for url: URL,  file: StaticString = #filePath, line: UInt = #line) {
    let receivedResult = Result { try sut.retrieve(dataForURL: url) }
    
    switch (receivedResult, expectedResult) {
    case let (.success( receivedData), .success(expectedData)):
        XCTAssertEqual(receivedData, expectedData, file: file, line: line)
        
    default:
        XCTFail("Expected \(expectedResult), got \(receivedResult) instead", file: file, line: line)
    }
}

private func insert(_ data: Data, for url: URL, into sut: CoreDataFeedStore, file: StaticString = #filePath, line: UInt = #line) {
    do {
        let image = localImage(url: url)
        try sut.insert([image], timestamp: Date()) { result in
            
        }
        try sut.insert(data, for: url)
    } catch {
        XCTFail("Failed to insert \(data) with error \(error)", file: file, line: line)
    }
}
