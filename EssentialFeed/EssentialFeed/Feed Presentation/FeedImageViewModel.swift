//
//  FeedImageViewModel.swift
//  EssentialFeediOS
//
//  Created by Denis Yaremenko on 08.02.2025.
//

public struct FeedImageViewModel {
    // we do not any detail about loading an image
    public let description: String?
    public let location: String?
     
    public var hasLocation: Bool {
        return location != nil
    }
}


