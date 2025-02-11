//
//  FeedErrorViewModel.swift
//  EssentialFeed
//
//  Created by Denis Yaremenko on 11.02.2025.
//

import Foundation

public struct FeedErrorViewModel {
    
    public let message: String?
    
    static var noError: FeedErrorViewModel {
        FeedErrorViewModel(message: nil)
    }
    
    static func error(message: String) -> FeedErrorViewModel {
        FeedErrorViewModel(message: message)
    }
}
