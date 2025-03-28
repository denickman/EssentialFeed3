//
//  SceneDelegate.swift
//  EssentialApp
//
//  Created by Denis Yaremenko on 13.02.2025.
//

import UIKit
import EssentialFeed
import EssentialFeediOS
import CoreData
import Combine

/* path to info.plist after build has been created
 ~/Library/Developer/Xcode/DerivedData/ТВОЙ_ПРОЕКТ/Build/Products/Debug-iphonesimulator/ТВОЙ_ПРОЕКТ.app/Info.plist
 */

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    // MARK: - Properties
    
    var window: UIWindow?
    
    private lazy var baseURL = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed")!
    
    private lazy var navigationController = UINavigationController(
        rootViewController: FeedUIComposer.feedComposedWith(
            feedLoader: makeRemoteFeedLoaderWithLocalFallback,
            imageLoader: makeLocalImageLoaderWithRemoteFallback,
            selection: showComments))
    
    private lazy var httpClient: HTTPClient = {
        URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
    }()
    
    private lazy var store: FeedStore & FeedImageDataStore = {
        do {
            return try CoreDataFeedStore(
                storeURL: NSPersistentContainer
                    .defaultDirectoryURL()
                    .appendingPathComponent("feed-store.sqlite"))
        } catch {
            assertionFailure("Failed to instantiate CoreData store with error \(error)")
            return NullStore()
        }
    }()
    
    private lazy var localFeedLoader: LocalFeedLoader = {
        LocalFeedLoader(store: store, currentDate: Date.init)
    }()
        
    // MARK: - Init
    
    convenience init(httpClient: HTTPClient, store: FeedStore & FeedImageDataStore) {
        self.init()
        self.httpClient = httpClient
        self.store = store
    }
    
    // MARK: - Lifecycle
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else { return }
        /// when initial screen loads from main.storyboard it creates the window for you automatically
        /// so without storyboard we need to create a window by our onw
        window = UIWindow(windowScene: scene)
        configureWindow()
    }
    
    // MARK: - Methods
    
    func configureWindow() {
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        localFeedLoader.validateCache { _ in }
    }
 
    private func makeFirstPage(items: [FeedImage]) -> Paginated<FeedImage> {
        makePage(items: items, last: items.last)
    }
    
    private func makePage(items: [FeedImage], last: FeedImage?) -> Paginated<FeedImage> {
        Paginated(
            items: items,
            loadMorePublisher: last.map { last in
                { self.makeRemoteLoadMoreLoader(items: items, last: last) }
                /// or use load from cache option, see method `makeRemoteLoadMoreLoader(last: FeedImage?)`
                /// { self.makeRemoteLoadMoreLoader(last: last) }
            })
    }
    
    private func makeRemoteFeedLoaderWithLocalFallback() -> AnyPublisher<Paginated<FeedImage>, Error> {
        /// Option 1
        //        let remoteFeedLoader = httpClient.getPublisher(url: remoteURL)
        //            .tryMap { (data, response) in
        //                try FeedItemsMapper.map(data, from: response)
        //            }
        //            .caching(to: localFeedLoader)
        //            .fallback(to: localFeedLoader.loadPublisher)
                
        /// Option 2
        return makeRemoteFeedLoader()
            .caching(to: localFeedLoader) // side effect
            .fallback(to: localFeedLoader.loadPublisher)
            .map(makeFirstPage) // $0 - [FeedImage] from .tryMap(FeedItemsMapper.map)
            .eraseToAnyPublisher()
    }
    
    // recursion
    private func makeRemoteLoadMoreLoader(items: [FeedImage], last: FeedImage?) -> AnyPublisher<Paginated<FeedImage>, Error> {
        return makeRemoteFeedLoader(after: last)
            .map { newItems in // receive new items
                (items + newItems, newItems.last) // combine with existing items
            }
            .map(makePage) // will return Paginated<FeedImage>
//            .delay(for: 2, scheduler: DispatchQueue.main)
//            .flatMap { _ in
//                Fail(error: NSError())
//            }
            .caching(to: localFeedLoader)
    }
    
    // recurstion # 2 if necessary - with cache in order to not increase the RAM
    private func makeRemoteLoadMoreLoader(last: FeedImage?) -> AnyPublisher<Paginated<FeedImage>, Error> {
            localFeedLoader.loadPublisher()
                .zip(makeRemoteFeedLoader(after: last))
                .map { (cachedItems, newItems) in
                    (cachedItems + newItems, newItems.last)
                }.map(makePage)
                .caching(to: localFeedLoader)
        }
    
    private func makeRemoteFeedLoader(after: FeedImage? = nil) -> AnyPublisher<[FeedImage], Error> {
        let url = FeedEndpoint.get(after: after).url(baseURL: baseURL)
        return httpClient
            .getPublisher(url: url) // side effect
            .tryMap(FeedItemsMapper.map) // // pure function
            .eraseToAnyPublisher()
    }
    
    private func makeLocalImageLoaderWithRemoteFallback(url: URL) -> FeedImageDataLoader.Publisher {
        
        let remoteImageLoader = RemoteFeedImageDataLoader(client: httpClient)
        let localImageLoader = LocalFeedImageDataLoader(store: store)
        
        return localImageLoader
            .loadImageDataPublisher(from: url)
            .fallback {
                remoteImageLoader
                    .loadImageDataPublisher(from: url)
                    .caching(to: localImageLoader, using: url)
            }
    }
    
    private func showComments(for image: FeedImage) {
        let url = ImageCommentsEndpoint.get(image.id).url(baseURL: baseURL)
        let comments = CommentsUIComposer.commentsComposedWith(commentsLoader: makeRemoteCommentsLoader(url: url))
        navigationController.pushViewController(comments, animated: true)
    }
    
    private func makeRemoteCommentsLoader(url: URL) -> () -> AnyPublisher<[ImageComment], Error> {
        return { [httpClient] in
            return httpClient
                .getPublisher(url: url)
                .tryMap(ImageCommentsMapper.map)
                .eraseToAnyPublisher()
        }
    }
}



















/*
 func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
 guard let _ = (scene as? UIWindowScene) else { return }
 
 let url = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed/v1/feed")!
 
 let session = URLSession(configuration: .ephemeral)
 let client = URLSessionHTTPClient(session: session)
 
 let feedLoader = RemoteFeedLoader(url: url, client: client)
 let imageLoader = RemoteFeedImageDataLoader(client: client)
 
 let feedViewController = FeedUIComposer.feedComposedWith(feedLoader: feedLoader, imageLoader: imageLoader)
 
 window?.rootViewController = feedViewController
 */

