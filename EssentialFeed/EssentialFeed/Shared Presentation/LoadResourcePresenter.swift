//
//  LoadResourcePresenter.swift
//  EssentialFeed
//
//  Created by Denis Yaremenko on 05.03.2025.
//

import Foundation

public final class LoadResourcePresenter {

    public static var title: String {
        NSLocalizedString(
            "FEED_VIEW_TITLE",
            tableName: "Feed",
            bundle: Bundle(for: FeedPresenter.self),
            comment: "title for the feed view"
        )
    }
    
    public var feedLoadError: String {
        NSLocalizedString(
            "FEED_VIEW_CONNECTION_ERROR",
            tableName: "Feed",
            bundle: Bundle(for: FeedPresenter.self),
            comment: "Error message displayed when we can't load the image feed from the server"
        )
    }
    
    // MARK: - Properties
    
    private let feedView: FeedView
    private let loadingView: FeedLoadingView
    private let errorView: FeedErrorView
    
    // MARK: - Init
    
    public init(feedView: FeedView, loadingView: FeedLoadingView, errorView: FeedErrorView) {
        self.feedView = feedView
        self.loadingView = loadingView
        self.errorView = errorView
    }
    
    // MARK: - Methods
    
    // Void -> creates view model -> sends to the UI
    public func didStartLoadingFeed() {
        errorView.display(.noError)
        loadingView.display(.init(isLoading: true))
    }
    
    // [FeedImage] -> creates view model -> sends to the UI
    // [ImageComment] -> creates view model -> sends to the UI
    // Resource -> ResourceViewModel -> sends to the UI
    public func didFinishLoadingFeed(with feed: [FeedImage]) {
        feedView.display(.init(feed: feed))
        loadingView.display(.init(isLoading: false))
    }
    
    // Error -> creates view model -> sends to the UI
    public func didFinishLoadingFeed(with error: Error) {
        errorView.display(.error(message: feedLoadError))
        loadingView.display(.init(isLoading: false))
    }
}
