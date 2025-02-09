//
//  FeedPresenter.swift
//  EssentialFeediOS
//
//  Created by Denis Yaremenko on 09.02.2025.
//

import EssentialFeed

struct FeedLoadingviewModel {
    var isLoading: Bool
}

protocol LoadingView {
    func display(_ viewModel: FeedLoadingviewModel)
}

struct FeedViewModel {
    var feed: [FeedImage]
}

protocol FeedView {
    func dislpay(_ viewModel: FeedViewModel)
}

final class FeedPresenter {

    // MARK: - Properties
    
    var feedView: FeedView?
    var loadingView: LoadingView?
    
    private let feedLoader: FeedLoader
    
    // MARK: - Init
    
    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
    
    // MARK: - Methods
    
    func loadFeed() {
        loadingView?.display(.init(isLoading: true))
        feedLoader.load { [weak self] result in
            if let feed = try? result.get() {
                self?.feedView?.dislpay(.init(feed: feed))
            }
            self?.loadingView?.display(.init(isLoading: false))
        }
    }
}
