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

final class LoadResourcePresentationAdapter<Resource, View: ResourceView> {
    
    // MARK: - Properties
    
    var presenter: LoadResourcePresenter<Resource, View>?
    private var cancellable: Cancellable?
    private let loader: () -> AnyPublisher<Resource, Error>
    private var isLoading = false // to prevent repeating loading process
    
    // MARK: - Init
    
    init(loader: @escaping () -> AnyPublisher<Resource, Error>) {
        self.loader = loader
    }
    
    func loadResource() {
        guard !isLoading else {
            return
        }
        presenter?.didStartLoading()
        isLoading = true
        
        cancellable = loader()
            .dispatchOnMainQueue()
            .handleEvents(receiveCancel: { [weak self] in
                self?.isLoading = false // if we cancel the loading process set isLoading to false
            })
            .sink { [weak self] completion in //sink происходят на главном потоке благодаря .dispatchOnMainQueue().
                switch completion {
                case .finished:
                    break
                    
                case let .failure(error):
                    self?.presenter?.didFinishLoading(with: error)
                }
                
                self?.isLoading = false
                
            } receiveValue: { [weak self] resource in
                self?.presenter?.didFinishLoading(with: resource) // because of send from class LoaderSpy: FeedImageDataLoader
            }
    }
}

extension LoadResourcePresentationAdapter: FeedImageCellControllerDelegate {
    func didRequestImage() {
        loadResource()
    }
    
    func didCancelImageRequest() {
        cancellable?.cancel()
        cancellable = nil
    }
}
