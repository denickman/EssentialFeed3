//
//  FeedLoaderPresentationAdapter.swift
//  EssentialFeediOS
//
//  Created by Denis Yaremenko on 10.02.2025.
//

import EssentialFeed
import EssentialFeediOS

/*
 Дополнительный слой адаптеров помогает разделить обязанности:
 Презентер (FeedImagePresenter) — отвечает за преобразование данных в модель для представления (ViewModel).
 Адаптер (WeakRefVirtualProxy) — отвечает за передачу данных во View.
 View (UIViewController) — отвечает за отображение данных.
 */

final class FeedLoaderPresentationAdapter {
    
    private let feedLoader: FeedLoader
    var presenter: FeedPresenter?
    
    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
}

extension FeedLoaderPresentationAdapter: FeedViewControllerDelegate {
    
    func didRequestFeedRefresh() {
        presenter?.didStartLoadingFeed()
        
        feedLoader.load { [weak self] result in
            switch result {
            case let .success(feed):
                self?.presenter?.didFinishLoadingFeed(with: feed)
                
            case let .failure(error):
                self?.presenter?.didFinishLoadingFeed(with: error)
            }
        }
    }
}
