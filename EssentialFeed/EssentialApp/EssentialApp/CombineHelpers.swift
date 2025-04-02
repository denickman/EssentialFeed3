//
//  EssentialApp.swift
//  EssentialApp
//
//  Created by Denis Yaremenko on 21.02.2025.
//

import Foundation
import Combine
import EssentialFeed

public extension Paginated {
    
    // converting publisher into closure
    init(items: [Item], loadMorePublisher: (() -> AnyPublisher<Self, Error>)?) {
        /// Subscribers.Sink - Это готовая реализация подписчика (Subscriber) из Combine.
        /// Метод subscribe привязывает Sink к publisher() (экземпляру AnyPublisher<Self, Error>).
        /// Sink начинает "слушать" события от publisher'а.
        ///
        /// Метод .map применяется к Optional и выполняет преобразование только если значение не nil. Если loadMorePublisher равно nil, результат тоже будет nil.
        self.init(items: items, loadMore: loadMorePublisher.map { publisher in
            return { completion in
                publisher().subscribe(Subscribers.Sink(receiveCompletion: { result in
                    switch result {
                    case .failure(let error):
                        completion(.failure(error))
                    case .finished:
                        break
                    }
                }, receiveValue: { value in
                    completion(.success(value))
                }))
            }
        })
    }
    
    // converting closure into publisher
    var loadMorePublisher: (() -> AnyPublisher<Self, Error>)? {
        
        // bridging from a closure into a publisher
        
        guard let loadMore = loadMore else { return nil }
        return {
            Deferred {
                Future(loadMore)
            }.eraseToAnyPublisher()
        }
    }
}


public extension HTTPClient {
    typealias Publisher = AnyPublisher<(Data, HTTPURLResponse), Error>
    
    func getPublisher(url: URL) -> Publisher {
        var task: HTTPClientTask?
        
        return Deferred {
            Future { completion in
                task = self.get(from: url, completion: completion)
            }
        }
        .handleEvents(receiveCancel: { task?.cancel() })
        .eraseToAnyPublisher()
    }
}

public extension FeedImageDataLoader {
    typealias Publisher = AnyPublisher<Data, Error>
    
    func loadImageDataPublisher(from url: URL) -> Publisher {
        Deferred {
                     Future { completion in
                         completion(Result {
                             try self.loadImageData(from: url)
                         })
                     }
                 }
        .eraseToAnyPublisher()
    }
}

extension Publisher where Output == Data {
    func caching(to cache: FeedImageDataCache, using url: URL) -> AnyPublisher<Output, Failure> {
        handleEvents(receiveOutput: { data in
            cache.saveIgnoringResult(data, for: url)
        }).eraseToAnyPublisher()
    }
}

private extension FeedImageDataCache {
    func saveIgnoringResult(_ data: Data, for url: URL) {
        try? save(data, for: url)
    }
}

public extension LocalFeedLoader {
    typealias Publisher = AnyPublisher<[FeedImage], Error>
    
    func loadPublisher() -> Publisher {
        Deferred {
            Future(self.load)
        }
        .eraseToAnyPublisher()
    }
}

extension Publisher {
    func fallback(to fallbackPublisher: @escaping () -> AnyPublisher<Output, Failure>) -> AnyPublisher<Output, Failure> {
        self.catch { _ in fallbackPublisher() }.eraseToAnyPublisher()
    }
}

extension Publisher { // where Output == [FeedImage]
    func caching(to cache: FeedCache) -> AnyPublisher<Output, Failure> where Output == [FeedImage] {
        handleEvents(receiveOutput: cache.saveIgnoringResult).eraseToAnyPublisher()
    }
    
    func caching(to cache: FeedCache) -> AnyPublisher<Output, Failure> where Output == Paginated<FeedImage> {
        handleEvents(receiveOutput: cache.saveIgnoringResult).eraseToAnyPublisher()
    }
}

private extension FeedCache {
    func saveIgnoringResult(_ feed: [FeedImage]) {
        save(feed) { _ in }
    }
    
    func saveIgnoringResult(_ page: Paginated<FeedImage>) {
        saveIgnoringResult(page.items)
    }
}

extension Publisher {
    func dispatchOnMainQueue() -> AnyPublisher<Output, Failure> {
        receive(on: DispatchQueue.immediateWhenOnMainQueueScheduler).eraseToAnyPublisher()
    }
}

extension DispatchQueue {
    static var immediateWhenOnMainQueueScheduler: ImmediateWhenOnMainQueueScheduler {
        ImmediateWhenOnMainQueueScheduler.shared
    }
    
    struct ImmediateWhenOnMainQueueScheduler: Scheduler {
        typealias SchedulerTimeType = DispatchQueue.SchedulerTimeType
        typealias SchedulerOptions = DispatchQueue.SchedulerOptions
        
        var now: SchedulerTimeType {
            DispatchQueue.main.now
        }
        
        var minimumTolerance: SchedulerTimeType.Stride {
            DispatchQueue.main.minimumTolerance
        }
        
        static let shared = Self()
        
        private static let key = DispatchSpecificKey<UInt8>()
        private static let value = UInt8.max
        
        private init() {
            DispatchQueue.main.setSpecific(key: Self.key, value: Self.value)
        }
        
        private func isMainQueue() -> Bool {
            DispatchQueue.getSpecific(key: Self.key) == Self.value // we are on the main queue
        }
        
        func schedule(options: SchedulerOptions?, _ action: @escaping () -> Void) {
            // the main queue is guaranteed to  be running on main thread
            // the main thread is not guaranteed to be running the main queue
            guard isMainQueue() else {
                return DispatchQueue.main.schedule(options: options, action)
            }
            
            action()
        }
        
        func schedule(after date: SchedulerTimeType, tolerance: SchedulerTimeType.Stride, options: SchedulerOptions?, _ action: @escaping () -> Void) {
            DispatchQueue.main.schedule(after: date, tolerance: tolerance, options: options, action)
        }
        
        func schedule(after date: SchedulerTimeType, interval: SchedulerTimeType.Stride, tolerance: SchedulerTimeType.Stride, options: SchedulerOptions?, _ action: @escaping () -> Void) -> Cancellable {
            DispatchQueue.main.schedule(after: date, interval: interval, tolerance: tolerance, options: options, action)
        }
    }
}


// craate own anyscheduler type erasure

typealias AnyDispatchQueueScheduler = AnyScheduler<DispatchQueue.SchedulerTimeType, DispatchQueue.SchedulerOptions>

// "стирает" конкретный тип реализации, предоставляя единый интерфейс для работы с любым объектом, соответствующим протоколу Scheduler.
struct AnyScheduler<SchedulerTimeType: Strideable, SchedulerOptions>: Scheduler
where SchedulerTimeType.Stride: SchedulerTimeIntervalConvertible {
    
/// SchedulerTimeType: Strideable — тип, представляющий "время" планировщика (например, DispatchQueue.SchedulerTimeType). Он должен поддерживать операции шага (stride), чтобы можно было задавать интервалы.
    ///
/// SchedulerOptions — тип опций планировщика (например, DispatchQueue.SchedulerOptions).
    ///
/// Ограничение: SchedulerTimeType.Stride: SchedulerTimeIntervalConvertible — шаг времени должен быть конвертируемым в интервал (это требование протокола Scheduler из Combine).
    ///
    private let _now: () -> SchedulerTimeType //  текущее время планировщика.
    private let _minimumTolerance: () -> SchedulerTimeType.Stride // минимальную допустимую погрешность.
    private let _schedule: (SchedulerOptions?, @escaping () -> Void) -> Void // немедленного выполнения действия
    private let _schedulerAfter: (SchedulerTimeType, SchedulerTimeType.Stride, SchedulerOptions?, @escaping () -> Void) -> Void // для планирования действия после определённого времени.
    private let _schedulerAfterInterval: (SchedulerTimeType, SchedulerTimeType.Stride, SchedulerTimeType.Stride, SchedulerOptions?, @escaping () -> Void) -> Cancellable // для планирования повторяющихся действий с интервалом

    var now: SchedulerTimeType {
        _now()
    }
    
    var minimumTolerance: SchedulerTimeType.Stride {
        _minimumTolerance()
    }
    
    init<S>(_ scheduler: S) where SchedulerTimeType == S.SchedulerTimeType,
    SchedulerOptions == S.SchedulerOptions, S: Scheduler {
        _now = { scheduler.now }
        _minimumTolerance = { scheduler.minimumTolerance }
        _schedule = scheduler.schedule(options:_:)
        _schedulerAfter = scheduler.schedule(after:tolerance:options:_:)
        _schedulerAfterInterval = scheduler.schedule(after:interval:tolerance:options:_:)
    }
    
    func schedule(options: SchedulerOptions?, _ action: @escaping () -> Void) {
        _schedule(options, action)
    }
    
    func schedule(after date: SchedulerTimeType, tolerance: SchedulerTimeType.Stride, options: SchedulerOptions?, _ action: @escaping () -> Void) {
        _schedulerAfter(date, tolerance, options, action)
    }
    
    func schedule(after date: SchedulerTimeType, interval: SchedulerTimeType.Stride, tolerance: SchedulerTimeType.Stride, options: SchedulerOptions?, _ action: @escaping () -> Void) -> any Cancellable {
        _schedulerAfterInterval(date, interval, tolerance, options, action)
    }
}

extension AnyDispatchQueueScheduler {
    static var immediateOnMainQueue: Self {
        DispatchQueue.immediateWhenOnMainQueueScheduler.eraseToAnyScheduler()
    }
}

extension Scheduler {
    func eraseToAnyScheduler() -> AnyScheduler<SchedulerTimeType, SchedulerOptions> {
        AnyScheduler(self)
    }
}
