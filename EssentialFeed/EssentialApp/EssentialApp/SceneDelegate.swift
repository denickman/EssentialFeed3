//
//  SceneDelegate.swift
//  EssentialApp
//
//  Created by Denis Yaremenko on 13.02.2025.
//

import os
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
    private lazy var logger = Logger(subsystem: "com.yaremenko.denis.Essential", category: "main") // main module
    
    // for not thread-safe operations & components
    private lazy var serialScheduler = DispatchQueue(label: "com.essentialdeveloper.infra.queue", qos: .userInitiated)
    
    // for thread-safe operations & components
    private lazy var concurrentScheduler = DispatchQueue(label: "com.essentialdeveloper.infra.queue", qos: .userInitiated, attributes: .concurrent)
    
    // Custom AnyScheduler type
    private lazy var customScheduler: AnyDispatchQueueScheduler = DispatchQueue(label: "com.essentialdeveloper.infra.queue", qos: .userInitiated, attributes: .concurrent).eraseToAnyScheduler()

        
    private lazy var navigationController = UINavigationController(
        rootViewController: FeedUIComposer.feedComposedWith(
            feedLoader: makeRemoteFeedLoaderWithLocalFallback,
            imageLoader: makeLocalImageLoaderWithRemoteFallback,
            selection: showComments))
    
    private lazy var httpClient: HTTPClient = {
        //  HTTPClientProfilingDecorator(decoratee: URLSessionHTTPClient(session: URLSession(configuration: .ephemeral)), logger: logger)
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
                    logger.fault("Failed to instantiate CoreData store with error \(error)")
        return NullStore()
                }
    }()
    
    private lazy var localFeedLoader: LocalFeedLoader = {
        LocalFeedLoader(store: store, currentDate: Date.init)
    }()
    
    // MARK: - Init
#if DEBUG
    convenience init(
        httpClient: HTTPClient,
        store: FeedStore & FeedImageDataStore,
        scheduler: AnyDispatchQueueScheduler
    ) {
        self.init()
        self.httpClient = httpClient
        self.store = store
        self.customScheduler = scheduler
    }
#endif
    
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
        //let client = HTTPClientProfilingDecorator(decoratee: httpClient, logger: logger)
        //let remoteImageLoader = RemoteFeedImageDataLoader(client: httpClient)
        let localImageLoader = LocalFeedImageDataLoader(store: store)
        
        
        // if your component is not thread-safe you need always execture operation in a serial queue (scheduler)
        return localImageLoader
            .loadImageDataPublisher(from: url)
            .logCacheMisses(url: url, logger: logger)
            .fallback(to: { [httpClient, logger, customScheduler] in
                return httpClient
                    .getPublisher(url: url)
                    .logErrors(url: url, logger: logger)
                    .logElapsedTime(url: url, logger: logger)
                    .tryMap(FeedImageDataMapper.map)
                    .caching(to: localImageLoader, using: url)
                    .subscribe(on: customScheduler)
                    .eraseToAnyPublisher()
            })
            // in order to not block MainQueue we subsribe localImageLoader results on another queue
            //.subscribe(on: DispatchQueue.global()) // concurrentQueue
            //.subscribe(on: serialScheduler) // serial Queue
            .subscribe(on: customScheduler) // concurrent Queue
           // no need to add  .receive(on: DispatchQueue.main) because PresentationAdapter already swith to MainQueue
            .eraseToAnyPublisher()
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

extension Publisher {
    
    func logCacheMisses(url: URL, logger: Logger) -> AnyPublisher<Output, Failure> {
          return handleEvents(receiveCompletion: { result in
            if case .failure = result {
                logger.trace(">> Cache miss url: \(url)")
            }
        })
        .eraseToAnyPublisher()
    }
    
    
    func logErrors(url: URL, logger: Logger) -> AnyPublisher<Output, Failure> {
        return handleEvents(receiveCompletion: { result in
            if case let .failure(error) = result {
                logger.trace(">> Failed to load url: \(url) with error: \(error)")
            }
        })
        .eraseToAnyPublisher()
    }
    
    func logElapsedTime(url: URL, logger: Logger) -> AnyPublisher<Output, Failure> {
        var startTime = CACurrentMediaTime()
        return handleEvents(
            receiveSubscription: { _ in
//                logger.trace(">> Started loading url: \(url)")
                startTime = CACurrentMediaTime()
            },
            receiveCompletion: { result in
                let elapsed = CACurrentMediaTime() - startTime
//                logger.trace(">> Finished loading url in \(elapsed) seconds.")
            })
        .eraseToAnyPublisher()
    }
}


// если не используем combine
private class HTTPClientProfilingDecorator: HTTPClient {
    
    private let decoratee: HTTPClient
    private let logger: Logger
    
    internal init(decoratee: any HTTPClient, logger: Logger) {
        self.decoratee = decoratee
        self.logger = logger
    }
    
    func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
        logger.trace(">> Started loading url: \(url)")
        let startTime = CACurrentMediaTime()
        return decoratee.get(from: url, completion: { [logger] result in
            
            if case let .failure(error) = result {
                logger.trace("FAILED to load url: \(url) with error: \(error)")
            }
            let elapsed = CACurrentMediaTime() - startTime
            logger.trace(">> Finished loading url in \(elapsed) seconds.")
            
            completion(result)
        })
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



