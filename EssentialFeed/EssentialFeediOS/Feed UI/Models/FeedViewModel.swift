//
//  FeedViewModel.swift
//  EssentialFeediOS
//
//  Created by Denis Yaremenko on 08.02.2025.
//

import Foundation
import EssentialFeed

final class FeedViewModel {

    // MARK: - Properties
    
    var onChange: ((FeedViewModel) -> Void)?
    var onFeedLoad: (([FeedImage]) -> Void)?
     
    private(set) var isLoading: Bool = false {
        didSet {
            onChange?(self)
        }
    }
    
    private let feedLoader: FeedLoader

    // MARK: - Init
    
    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
    
    // MARK: - Methods
    
    func loadFeed() {
        isLoading = true
        feedLoader.load { [weak self] result in
            if let feed = try? result.get() {
                self?.onFeedLoad?(feed)
            }
            self?.isLoading = false
        }
    }
    
}
