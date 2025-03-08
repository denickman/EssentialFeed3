//
//  CommentsUIComposer.swift
//  EssentialApp
//
//  Created by Denis Yaremenko on 08.03.2025.
//

import UIKit
import Combine
import EssentialFeed
import EssentialFeediOS

public final class CommentsUIComposer {
    
    private init() {}
    
    public static func commentsComposedWith(
        commentsLoader: @escaping () -> AnyPublisher<[FeedImage], Error>
    ) -> ListViewController {
        
        let presentationAdapter = LoadResourcePresentationAdapter<[FeedImage], FeedViewAdapter>(
            loader: { commentsLoader().dispatchOnMainQueue() })
        
        let feedController = makeFeedViewController(title: ImageCommentsPresenter.title)
         
        feedController.onRefresh = presentationAdapter.loadResource
        
        let feedViewAdapter = FeedViewAdapter(
            controller: feedController,
            imageLoader: { _ in Empty<Data, Error>().eraseToAnyPublisher() }
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
    
    private static func makeFeedViewController(title: String) -> ListViewController {
        let bundle = Bundle(for: ListViewController.self)
        let storyboard = UIStoryboard(name: "ImageComments", bundle: bundle)
        let feedController = storyboard.instantiateInitialViewController() as! ListViewController
        feedController.title = title
        return feedController
    }
}
