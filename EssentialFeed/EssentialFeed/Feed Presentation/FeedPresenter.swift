//
//  FeedPresenter.swift
//  EssentialFeed
//
//  Created by Denis Yaremenko on 11.02.2025.
//

import Foundation

public final class FeedPresenter {
    
    public static var title: String {
        NSLocalizedString(
            "FEED_VIEW_TITLE",
            tableName: "Feed",
            bundle: Bundle(for: FeedPresenter.self),
            comment: "title for the feed view"
        )
    }

    // MARK: - Methods
    
    public static func map(_ feed: [FeedImage]) -> FeedViewModel {
        FeedViewModel(feed: feed)
    }
}
