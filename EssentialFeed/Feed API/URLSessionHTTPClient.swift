//
//  URLSessionHTTPClient.swift
//  EssentialFeed
//
//  Created by Denis Yaremenko on 21.01.2025.
//

import Foundation

public class URLSessionHTTPClient: HTTPClient {
    
    private struct UnexpectedValueRepresentation: Error {}

    private let session: URLSession
    
    public init(session: URLSession = .shared) {
        self.session = session
    }
    
    public func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
        session.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
            } else if let data = data, let response = response as? HTTPURLResponse {
                completion(.success(data, response))
            } else {
                completion(.failure(UnexpectedValueRepresentation()))
            }
        }.resume()
    }
}

