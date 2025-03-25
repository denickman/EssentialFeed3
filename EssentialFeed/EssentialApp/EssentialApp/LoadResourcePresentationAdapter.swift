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
    
    // MARK: - Init
    
    init(loader: @escaping () -> AnyPublisher<Resource, Error>) {
        self.loader = loader
    }
    
    func loadResource() {
        presenter?.didStartLoading()
        
        cancellable = loader()
            .dispatchOnMainQueue()
            .sink { [weak self] completion in
                switch completion {
                case .finished: break
                case let .failure(error):
                    self?.presenter?.didFinishLoading(with: error)
                }
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
