//
//  RemoteFeedItem.swift
//  EssentialFeed
//
//  Created by Denis Yaremenko on 26.01.2025.
//

import Foundation

struct RemoteFeedItem: Decodable {
    let id: UUID
    let description: String?
    let location: String?
    let image: URL
}

