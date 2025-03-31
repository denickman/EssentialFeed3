//
//  FeedImageDataLoader.swift
//  EssentialFeediOS
//
//  Created by Denis Yaremenko on 06.02.2025.
//

import Foundation

// FeedImageDataLoaderTask относится к уровню загрузки изображений (работает с FeedImageDataLoader).
// async api
//public protocol FeedImageDataLoaderTask {
//    func cancel()
//}

public protocol FeedImageDataLoader {
    // async api
//    typealias Result = Swift.Result<Data, Error>
//    func loadImageData(from url: URL, completion: @escaping (Result) -> Void) -> FeedImageDataLoaderTask
    
    func loadImageData(from url: URL) throws -> Data
}
