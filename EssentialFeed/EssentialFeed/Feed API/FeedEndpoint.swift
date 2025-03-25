//
//  FeedEndpoint.swift
//  EssentialFeed
//
//  Created by Denis Yaremenko on 09.03.2025.
//


import Foundation

public enum FeedEndpoint {
    case get

    public func url(baseURL: URL) -> URL {
        switch self {
        case .get:
//            return baseURL.appendingPathComponent("/v1/feed")
            var components = URLComponents()
            components.scheme = baseURL.scheme
            components.host = baseURL.host
            components.path = baseURL.path() + "/v1/feed"
            components.queryItems = [URLQueryItem(name: "limit", value: "10")]
            return components.url!
        }
    }
}
