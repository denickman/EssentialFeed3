//
//  Paginated.swift
//  EssentialFeed
//
//  Created by Denis Yaremenko on 24.03.2025.
//

import Foundation

//@escaping находится внутри — ((@escaping LoadMoreCompletion) -> Void)? — потому что оно относится к параметру LoadMoreCompletion, который передаётся в loadMore и будет вызван асинхронно (например, после загрузки данных).
//@escaping не снаружи, потому что само замыкание loadMore не "убегает" из структуры — оно просто хранится как свойство и вызывается явно в нужный момент.
//Это сделано так, чтобы поддерживать асинхронное поведение completion в таких случаях, как DispatchQueue.async, что и ожидается от пагинации.

public struct Paginated<Item> {
    // public typealias LoadMoreCompletion = (Result<Paginated<Item>, Error>) -> Void
     public typealias LoadMoreCompletion = (Result<Self, Error>) -> Void // Self == Paginated<Item>

    public let items: [Item]
    public let loadMore: ((@escaping LoadMoreCompletion) -> Void)?

    public init(items: [Item], loadMore: ((@escaping LoadMoreCompletion) -> Void)? = nil) {
        self.items = items
        self.loadMore = loadMore
    }
}
