//
//  FeedUIComposer.swift
//  EssentialFeediOS
//
//  Created by Denis Yaremenko on 06.02.2025.
//

import UIKit
import Combine
import EssentialFeed
import EssentialFeediOS

public final class FeedUIComposer {
    
    private init() {}
    
    public static func feedComposedWith(
        feedLoader: @escaping () -> AnyPublisher<[FeedImage], Error>,
        imageLoader: @escaping (URL) -> FeedImageDataLoader.Publisher
    ) -> FeedViewController {
        
        let presentationAdapter = LoadResourcePresentationAdapter<[FeedImage], FeedViewAdapter>(
            loader: { feedLoader().dispatchOnMainQueue() })
        
        let feedController = makeFeedViewController(delegate: presentationAdapter, title: FeedPresenter.title)
        
        let feedViewAdapter = FeedViewAdapter(
            controller: feedController,
            imageLoader: { imageLoader($0).dispatchOnMainQueue() }
        )
        
        let resourcePresenter = LoadResourcePresenter(
            resourceView: feedViewAdapter,
            loadingView: WeakRefVirtualProxy(feedController),
            errorView: WeakRefVirtualProxy(feedController),
            mapper: FeedPresenter.map
        )
        
        presentationAdapter.presenter = resourcePresenter
        
        return feedController
    }
    
    private static func makeFeedViewController(delegate: FeedViewControllerDelegate, title: String) -> FeedViewController {
        let bundle = Bundle(for: FeedViewController.self)
        let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
        let feedController = storyboard.instantiateInitialViewController() as! FeedViewController
        feedController.delegate = delegate
        feedController.title = FeedPresenter.title
        return feedController
    }
}

