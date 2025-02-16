//
//  EssentialAppUIAcceptanceTests.swift
//  EssentialAppUIAcceptanceTests
//
//  Created by Denis Yaremenko on 16.02.2025.
//

import XCTest

final class EssentialAppUIAcceptanceTests: XCTestCase {
    
    func test_onLaunch_displaysRemoteFeedWhenCustomerHasConnectivity() {
        let app = XCUIApplication()
        app.launch()
        
        let feedCells = app.cells.matching(identifier: "feed-image-cell")
        XCTAssertEqual(feedCells.count, 22)
        
        let feedImage = app.images.matching(identifier: "feed-image-view").firstMatch
        XCTAssertTrue(feedImage.exists)
    }


}
