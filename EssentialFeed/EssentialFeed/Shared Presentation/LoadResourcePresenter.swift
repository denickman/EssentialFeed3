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

    // since now we have sevral tables of localized strings
    public static var loadError: String {
        NSLocalizedString(
            "GENERIC_CONNECTION_ERROR",
            tableName: "Shared",
            bundle: Bundle(for: Self.self),
            comment: "Error message displayed when we can't load the resource feed from the server"
        )
    }
    
    // MARK: - Properties
    
    public typealias Mapper = (Resource) throws -> View.ResourceViewModel
    
    private let resourceView: View
    private let loadingView: ResourceLoadingView
    private let errorView: ResourceErrorView
    private let mapper: Mapper
    
    // MARK: - Init
    
    public init(
        resourceView: View,
        loadingView: ResourceLoadingView,
        errorView: ResourceErrorView,
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
        do {
            resourceView.display(try mapper(resource))
            loadingView.display(.init(isLoading: false))
        } catch {
            didFinishLoading(with: error)
        }
    }
    
    // Error -> creates view model -> sends to the UI
    public func didFinishLoading(with error: Error) {
        errorView.display(.error(message: Self.loadError))
        loadingView.display(.init(isLoading: false))
    }
}
