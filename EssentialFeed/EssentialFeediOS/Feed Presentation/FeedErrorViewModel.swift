//
//  FeedErrorViewModel.swift
//  EssentialFeediOS
//
//  Created by Denis Yaremenko on 11.02.2025.
//

import Foundation

struct FeedErrorViewModel {
    let message: String?
    
    static var noError: FeedErrorViewModel {
        FeedErrorViewModel(message: nil)
    }
    
    static func error(message: String) -> FeedErrorViewModel {
        FeedErrorViewModel(message: message)
    }
}
