//
//  FeedImagePresenter.swift
//  EssentialFeediOS
//
//  Created by Denis Yaremenko on 09.02.2025.

import Foundation

public final class FeedImagePresenter {
    public static func map(_ feed: FeedImage) -> FeedImageViewModel {
        FeedImageViewModel(
            description: feed.description,
            location: feed.location
        )
    }
}
