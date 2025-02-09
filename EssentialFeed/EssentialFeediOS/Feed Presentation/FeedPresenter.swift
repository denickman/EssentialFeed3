//
//  FeedPresenter.swift
//  EssentialFeediOS
//
//  Created by Denis Yaremenko on 09.02.2025.
//

import EssentialFeed


struct FeedLoadingviewModel {
    /// it only holds the necessary data, no behaviors
    var isLoading: Bool
}

protocol LoadingView {
    func display(_ viewModel: FeedLoadingviewModel)
}

struct FeedViewModel {
    /// it only holds the necessary data, no behaviors
    var feed: [FeedImage]
}

protocol FeedView {
    func dislpay(_ viewModel: FeedViewModel)
}

final class FeedPresenter {
    
    private let feedView: FeedView
    private let loadingView: LoadingView
    
    init(feedView: FeedView, loadingView: LoadingView) {
        self.feedView = feedView
        self.loadingView = loadingView
    }
    
    func didStartLoadingFeed() {
        loadingView.display(.init(isLoading: true))
    }
    
    func didFinishLoadingFeed(with feed: [FeedImage]) {
        feedView.dislpay(.init(feed: feed))
        loadingView.display(.init(isLoading: false))
    }
    
    func didFinishLoadingFeed(with error: Error) {
        loadingView.display(.init(isLoading: false))
    }
    
}
