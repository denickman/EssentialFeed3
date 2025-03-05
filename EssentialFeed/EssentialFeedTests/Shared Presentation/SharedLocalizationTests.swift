//
//  SharedLocalizationTests.swift
//  EssentialFeedTests
//
//  Created by Denis Yaremenko on 05.03.2025.
//

import XCTest
import EssentialFeed

final class SharedLocalizationTests: XCTestCase {
    
    func test_localizedStrings_haveKeysAndValuesForAllSupportedLocalizations() {
        let table = "Shared"
        let bundle = Bundle(for: LoadResourcePresenter<Any, DummyView>.self)
        assertLocalizedKeyAndValuesExist(bundle, table)
    }
    
    private class DummyView: ResourceView {
        func display(_ viewModel: Any) { }
    }
}



