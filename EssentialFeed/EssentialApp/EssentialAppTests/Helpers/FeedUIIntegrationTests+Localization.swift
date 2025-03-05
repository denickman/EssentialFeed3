//
//  FeedUIIntegrationTests+Localization.swift
//  EssentialFeediOSTests
//
//  Created by Denis Yaremenko on 10.02.2025.
//

import Foundation
import XCTest
import EssentialFeed

extension FeedUIIntegrationTests {
    
    private class DummyView: ResourceView {
        func display(_ viewModel: Any) {
            
        }
    }
    
    var loadError: String {
        LoadResourcePresenter<Any, DummyView>.loadError
    }
    
    var feedTitle: String {
        FeedPresenter.title
    }

}
