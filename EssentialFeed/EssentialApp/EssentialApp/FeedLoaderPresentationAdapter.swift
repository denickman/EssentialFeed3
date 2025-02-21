//
//  FeedLoaderPresentationAdapter.swift
//  EssentialFeediOS
//
//  Created by Denis Yaremenko on 10.02.2025.
//

import EssentialFeed
import EssentialFeediOS
import Combine

/*
 Дополнительный слой адаптеров помогает разделить обязанности:
 Презентер (FeedImagePresenter) — отвечает за преобразование данных в модель для представления (ViewModel).
 Адаптер (WeakRefVirtualProxy) — отвечает за передачу данных во View.
 View (UIViewController) — отвечает за отображение данных.
 */

final class FeedLoaderPresentationAdapter {
    
    private var cancellable: Cancellable?
    
    private let feedLoader: () -> FeedLoader.Publisher
    var presenter: FeedPresenter?
    
    init(feedLoader: @escaping () -> FeedLoader.Publisher) {
        self.feedLoader = feedLoader
    }
}

extension FeedLoaderPresentationAdapter: FeedViewControllerDelegate {
    
    func didRequestFeedRefresh() {
        presenter?.didStartLoadingFeed()
        
        cancellable = feedLoader()
            .sink { [weak self] completion in
                switch completion {
                case .finished: break
                case let .failure(error):
                    self?.presenter?.didFinishLoadingFeed(with: error)
                }
            } receiveValue: { [weak self] feed in
                self?.presenter?.didFinishLoadingFeed(with: feed)
            }
    }
}
