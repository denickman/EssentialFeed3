//
//  ImageCommentsLocalizationTests.swift
//  EssentialFeedTests
//
//  Created by Denis Yaremenko on 06.03.2025.
//

import XCTest
import EssentialFeed

final class ImageCommentsLocalizationTests: XCTestCase {
    
    func test_localizedStrings_haveKeysAndValuesForAllSupportedLocalizations() {
        let table = "ImageComments"
        let bundle = Bundle(for: ImageCommentsPresenter.self)
        assertLocalizedKeyAndValuesExist(bundle, table)
    }

}
