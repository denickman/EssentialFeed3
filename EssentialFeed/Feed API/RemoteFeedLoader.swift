//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Denis Yaremenko on 19.01.2025.
//

import Foundation

public final class RemoteFeedLoader: FeedLoader {
    
    public typealias Result = LoadFeedResult

    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    private let url: URL
    private let client: HTTPClient
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public func load(completion: @escaping (LoadFeedResult) -> Void ) {
        client.get(from: url) { [weak self] result in
            
            guard self != nil else { return }
            
            switch result {
            case let .success(data, response):
                completion(FeedItemsMapper.map(data, from: response))

            case .failure:
                completion(.failure(Error.connectivity))
            }
        }
    }

}
