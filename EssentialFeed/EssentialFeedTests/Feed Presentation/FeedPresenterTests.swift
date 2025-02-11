//
//  FeedPresenterTests.swift
//  EssentialFeedTests
//
//  Created by Denis Yaremenko on 11.02.2025.
//

import XCTest

final class FeedPresenter {
    init(view: Any) {
        
    }
}


class FeedPresenterTests: XCTestCase {
    
    func test_init_doesNotSendMessagesToView() {
        let (_, view) = makeSUT()
        XCTAssertTrue(view.messages.isEmpty, "Expected no view messages")
    }
    
//    func test_didStartLoadingFeed_displaysNoErrorMessage() {
//        let (_, view) = makeSUT()
//        XCTAssertEqual(view.messages, [.display(.noError)])
//    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedPresenter, view: ViewSpy) {
        let view = ViewSpy()
        let sut = FeedPresenter(view: view)
        trackForMemoryLeaks(view, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, view)
    }
    
    private class ViewSpy {
        
//        enum Message {
//            case display()
//        }
        
        let messages = [Any]()
    }
    
}
