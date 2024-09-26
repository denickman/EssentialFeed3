//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Denis Yaremenko on 19.01.2025.
//

import Foundation

public final class RemoteFeedLoader: FeedLoader {
    
    public typealias Result = FeedLoader.Result

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
    
    public func load(completion: @escaping (FeedLoader.Result) -> Void ) {
        client.get(from: url) { [weak self] result in
            
            guard self != nil else { return }
            
            switch result {
            case let .success(data, response):
                completion(RemoteFeedLoader.map(data, from: response))

            case .failure:
                completion(.failure(Error.connectivity))
            }
        }
    }
    
    private static func map(_ data: Data, from response: HTTPURLResponse) -> Result {
        do {
            let items = try FeedItemsMapper.map(data, from: response)
            return .success(items.toModels())
        } catch {
            return .failure(error)
        }
    }

}

private extension Array where Element == RemoteFeedItem {
    func toModels() -> [FeedImage] {
        map {
            .init(id: $0.id, description: $0.description, location: $0.location, url: $0.image)
        }
    }
}
