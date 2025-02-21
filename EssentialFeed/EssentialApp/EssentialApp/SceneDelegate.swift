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
    
    var window: UIWindow?
    
    private lazy var remoteURL = URL(string: "https://static1.squarespace.com/static/5891c5b8d1758ec68ef5dbc2/t/5db4155a4fbade21d17ecd28/1572083034355/essential_app_feed.json")!
    
    /// Since iOS 14, if we don't explicitly hold a reference to the RemoteFeedLoader instance, it'll be deallocated before it completes the operation
    private lazy var remoteFeedLoader = RemoteFeedLoader(url: remoteURL, client: httpClient)
    
    private lazy var httpClient: HTTPClient = {
        URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
    }()
    
    private lazy var store: FeedStore & FeedImageDataStore = {
        try! CoreDataFeedStore(
            storeURL: NSPersistentContainer
                .defaultDirectoryURL()
                .appendingPathComponent("feed-store.sqlite"))
    }()
    
    private lazy var localFeedLoader: LocalFeedLoader = {
        LocalFeedLoader(store: store, currentDate: Date.init)
    }()
    
    convenience init(httpClient: HTTPClient, store: FeedStore & FeedImageDataStore) {
        self.init()
        self.httpClient = httpClient
        self.store = store
    }
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else { return }
        /// when initial screen loads from main.storyboard it creates the window for you automatically
        /// so without storyboard we need to create a window by our onw
        window = UIWindow(windowScene: scene)
        configureWindow()
    }
    
    func configureWindow() {

        let remoteImageLoader = RemoteFeedImageDataLoader(client: httpClient)
        let localImageLoader = LocalFeedImageDataLoader(store: store)
        
        window?.rootViewController = UINavigationController(
            rootViewController: FeedUIComposer.feedComposedWith(
                
                feedLoader: makeRemoteFeedLoaderWithLocalFallback,
                
                imageLoader: FeedImageDataLoaderWithFallbackComposite(
                    primary: localImageLoader,
                    fallback: FeedImageDataLoaderCacheDecorator(
                        decoratee: remoteImageLoader,
                        cache: localImageLoader))))
        
        window?.makeKeyAndVisible()
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        localFeedLoader.validateCache { _ in }
    }
    
    func makeRemoteFeedLoaderWithLocalFallback() -> FeedLoader.Publisher {
        
     
        
        //        return Deferred { Future(remoteFeedLoader.load) }.eraseToAnyPublisher()
        return remoteFeedLoader
            .loadPublisher()
            .caching(to: localFeedLoader)
            .fallback(to: localFeedLoader.loadPublisher)
    }
}

public extension FeedLoader {
    typealias Publisher = AnyPublisher<[FeedImage], Error>
    
    func loadPublisher() -> Publisher {
         Deferred {
            Future { completion in
                self.load(completion: completion)
            }
        }
        .eraseToAnyPublisher()
    }
}

extension Publisher where Output == [FeedImage] {
    func caching(to cache: FeedCache) -> AnyPublisher<Output, Failure> {
        // handleEvents(receiveOutput: cache.saveIgnoringResult).eraseToAnyPublisher()
        handleEvents(receiveOutput: { feed in
            cache.saveIgnoringResult(feed)
        })
        .eraseToAnyPublisher()
    }
}

extension Publisher {
    func fallback(to fallbackPublisher: @escaping () -> AnyPublisher<Output, Failure>) ->  AnyPublisher<Output, Failure> {
//        self.catch(fallbackPublisher).eraseToAnyPublisher()
        self.catch { _ in
            fallbackPublisher()
        }
        .eraseToAnyPublisher()
    }
}

extension Publisher {
    func dispatchOnMain() -> AnyPublisher<Output, Failure> {
       /// receive(on: DispatchQueue.main).eraseToAnyPublisher() // will always call asynchroniously
        receive(on: DispatchQueue.immediateWhenOnmainQueueScheduler).eraseToAnyPublisher()
    }
}

extension DispatchQueue {
    
    static var immediateWhenOnmainQueueScheduler: ImmediateWhenOnMainQueueScheduler {
        ImmediateWhenOnMainQueueScheduler()
    }
         
    struct ImmediateWhenOnMainQueueScheduler: Scheduler {
        typealias SchedulerTimeType = DispatchQueue.SchedulerTimeType
        typealias SchedulerOptions = DispatchQueue.SchedulerOptions

        /// This scheduler’s definition of the current moment in time.
        var now: Self.SchedulerTimeType {
            DispatchQueue.main.now
        }

        /// The minimum tolerance allowed by the scheduler.
        var minimumTolerance: Self.SchedulerTimeType.Stride {
            DispatchQueue.main.minimumTolerance
        }

        /// Performs the action at the next possible opportunity.
        func schedule(options: Self.SchedulerOptions?, _ action: @escaping () -> Void) {
            guard Thread.isMainThread else {
                return DispatchQueue.main.schedule(options: options, action)
            }
            action()
        }

        /// Performs the action at some time after the specified date.
        func schedule(after date: Self.SchedulerTimeType, tolerance: Self.SchedulerTimeType.Stride, options: Self.SchedulerOptions?, _ action: @escaping () -> Void) {
            DispatchQueue.main.schedule(after: date, tolerance: tolerance, options: options, action)
        }

        /// Performs the action at some time after the specified date, at the specified frequency, optionally taking into account tolerance if possible.
        func schedule(after date: Self.SchedulerTimeType, interval: Self.SchedulerTimeType.Stride, tolerance: Self.SchedulerTimeType.Stride, options: Self.SchedulerOptions?, _ action: @escaping () -> Void) -> any Cancellable {
            DispatchQueue.main.schedule(after: date, interval: interval, tolerance: tolerance, options: options, action)
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

