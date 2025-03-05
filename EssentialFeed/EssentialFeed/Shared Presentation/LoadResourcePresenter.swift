//
//  LoadResourcePresenter.swift
//  EssentialFeed
//
//  Created by Denis Yaremenko on 05.03.2025.
//

import Foundation

public protocol ResourceView {
    associatedtype ResourceViewModel
    func display(_ viewModel: ResourceViewModel)
}
     
public final class LoadResourcePresenter<Resource, View: ResourceView> {

    public var feedLoadError: String {
        NSLocalizedString(
            "GENERIC_CONNECTION_ERROR",
            tableName: "Feed",
            bundle: Bundle(for: FeedPresenter.self),
            comment: "Error message displayed when we can't load the image feed from the server"
        )
    }
    
    // MARK: - Properties
    
    public typealias Mapper = (Resource) -> View.ResourceViewModel
    
    private let resourceView: View
    private let loadingView: FeedLoadingView
    private let errorView: FeedErrorView
    private let mapper: Mapper
    
    // MARK: - Init
    
    public init(
        resourceView: View,
        loadingView: FeedLoadingView,
        errorView: FeedErrorView,
        mapper: @escaping Mapper
    ) {
        self.resourceView = resourceView
        self.loadingView = loadingView
        self.errorView = errorView
        self.mapper = mapper
    }
    
    // MARK: - Methods
    
    // Void -> creates view model -> sends to the UI
    public func didStartLoading() {
        errorView.display(.noError)
        loadingView.display(.init(isLoading: true))
    }
    
    // [FeedImage] -> creates view model -> sends to the UI
    // [ImageComment] -> creates view model -> sends to the UI
    // Resource -> ResourceViewModel -> sends to the UI
    public func didFinishLoading(with resource: Resource) {
        resourceView.display(mapper(resource))
        loadingView.display(.init(isLoading: false))
    }
    
    // Error -> creates view model -> sends to the UI
    public func didFinishLoading(with error: Error) {
        errorView.display(.error(message: feedLoadError))
        loadingView.display(.init(isLoading: false))
    }
}
