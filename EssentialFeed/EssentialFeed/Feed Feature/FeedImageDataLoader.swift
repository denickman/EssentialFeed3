//
//  FeedImageDataLoader.swift
//  EssentialFeediOS
//
//  Created by Denis Yaremenko on 06.02.2025.
//

import Foundation

// FeedImageDataLoaderTask относится к уровню загрузки изображений (работает с FeedImageDataLoader).
// ASync API
//public protocol FeedImageDataLoaderTask {
//    func cancel()
//}

public protocol FeedImageDataLoader {
    // ASync API
//    typealias Result = Swift.Result<Data, Error>
//    func loadImageData(from url: URL, completion: @escaping (Result) -> Void) -> FeedImageDataLoaderTask
    
    func loadImageData(from url: URL) throws -> Data
}
