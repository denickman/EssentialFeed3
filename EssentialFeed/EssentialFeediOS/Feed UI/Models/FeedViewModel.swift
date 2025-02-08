//
//  FeedViewModel.swift
//  EssentialFeediOS
//
//  Created by Denis Yaremenko on 08.02.2025.
//

import Foundation
import EssentialFeed

final class FeedViewModel {
    
    typealias Observer<T> = (T) -> Void
    
    // MARK: - Properties
    
    var onLoadingStateChange: (Observer<Bool>)?
    var onFeedLoad: (Observer<[FeedImage]>)?
    
    private let feedLoader: FeedLoader
    
    // MARK: - Init
    
    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
    
    // MARK: - Methods
    
    func loadFeed() {
        onLoadingStateChange?(true)
        feedLoader.load { [weak self] result in
            if let feed = try? result.get() {
                self?.onFeedLoad?(feed)
            }
            self?.onLoadingStateChange?(false)
        }
    }
    
}
