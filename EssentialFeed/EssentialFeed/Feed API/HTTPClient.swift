//
//  HTTPClient.swift
//  EssentialFeed
//
//  Created by Denis Yaremenko on 20.01.2025.
//

import Foundation

/// HTTPClientTask относится к сетевому уровню (работает с HTTPClient).
/// 
public protocol HTTPClientTask {
    func cancel()
}

public protocol HTTPClient {
    typealias Result = Swift.Result<(Data, HTTPURLResponse), Error>
    
    /// The completion handler can be invoked in any thread.
    /// Clients are responsible to dispatch to appropriate threads, if needed.
    @discardableResult
    func get(from url: URL, completion: @escaping (Result) -> Void) -> HTTPClientTask
}

