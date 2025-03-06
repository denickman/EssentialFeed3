//
//  ImageCommentsPresenter.swift
//  EssentialFeed
//
//  Created by Denis Yaremenko on 06.03.2025.
//

import Foundation

public final class ImageCommentsPresenter {
    
    public static var title: String {
        NSLocalizedString(
            "IMAGE_COMMENTS_VIEW_TITLE",
            tableName: "ImageComments",
            bundle: Bundle(for: Self.self),
            comment: "title for the image comments view"
        )
    }
}
