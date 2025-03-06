//
//  FeedImagePresenter.swift
//  EssentialFeediOS
//
//  Created by Denis Yaremenko on 09.02.2025.

import Foundation

/*
 Если бы мы использовали замыкание (closure) вместо делегата, презентер стал бы ответственным за две вещи:
 (1) обработку данных
 (2) обновление UI
 Это нарушает SRP и делает код менее гибким.
 */

public protocol FeedImageView {
    associatedtype Image
    func display(_ model: FeedImageViewModel<Image>)
}

public final class FeedImagePresenter<View: FeedImageView, Image> where View.Image == Image {
    
    private let view: View // <— сильная ссылка на view
    private let imageTransformer: (Data) -> Image?
    
    public init(view: View, imageTransformer: @escaping (Data) -> Image?) {
        self.view = view // <— сильная ссылка может привести к retain cycle
        self.imageTransformer = imageTransformer
    }
    
    public func didStartLoadingImageData(for model: FeedImage) {
        view.display(
            FeedImageViewModel(
                description: model.description,
                location: model.location,
                image: nil,
                isLoading: true,
                shouldRetry: false
            )
        )
    }
    
    public func didFinishLoadingImageData(with data: Data, for model: FeedImage) {
        let image = imageTransformer(data)
        
        view.display(
            FeedImageViewModel(
                description: model.description,
                location: model.location,
                image: image,
                isLoading: false,
                shouldRetry: image == nil
            )
        )
    }
    
    public func didFinishLoadingImageData(with error: Error, for model: FeedImage) {
        view.display(
            FeedImageViewModel(
                description: model.description,
                location: model.location,
                image: nil,
                isLoading: false,
                shouldRetry: true
            )
        )
    }
    
    public static func map(_ feed: FeedImage) -> FeedImageViewModel<Image> {
        FeedImageViewModel(
            description: feed.description,
            location: feed.location,
            image: nil,
            isLoading: false,
            shouldRetry: false
        )
    }
}
