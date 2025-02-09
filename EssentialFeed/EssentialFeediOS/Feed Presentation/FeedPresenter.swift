//
//  FeedPresenter.swift
//  EssentialFeediOS
//
//  Created by Denis Yaremenko on 09.02.2025.
//

import EssentialFeed

protocol LoadingView: AnyObject {
    func display(isLoading: Bool)
}

protocol FeedView {
    func dislpay(feed: [FeedImage])
}

final class FeedPresenter {

    // MARK: - Properties
    
    var feedView: FeedView?
    weak var loadingView: LoadingView?
    
    private let feedLoader: FeedLoader
    
    // MARK: - Init
    
    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
    
    // MARK: - Methods
    
    func loadFeed() {
        loadingView?.display(isLoading: true)
        feedLoader.load { [weak self] result in
            if let feed = try? result.get() {
                self?.feedView?.dislpay(feed: feed)
            }
            self?.loadingView?.display(isLoading: true)
        }
    }
}
