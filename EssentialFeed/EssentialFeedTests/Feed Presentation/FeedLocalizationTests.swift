//
//  FeedLocalizationTests.swift
//  EssentialFeediOSTests
//
//  Created by Denis Yaremenko on 10.02.2025.
//

import XCTest
import EssentialFeed

final class FeedLocalizationTests: XCTestCase {
    
    func test_localizedStrings_haveKeysAndValuesForAllSupportedLocalizations() {
        let table = "Feed"
        let bundle = Bundle(for: FeedPresenter.self)
        assertLocalizedKeyAndValuesExist(bundle, table)
    }
}

