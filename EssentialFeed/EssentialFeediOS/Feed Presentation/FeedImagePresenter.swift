//
//  FeedImagePresenter.swift
//  EssentialFeediOS
//
//  Created by Denis Yaremenko on 09.02.2025.

import Foundation
import EssentialFeed

/*
 Если бы мы использовали замыкание (closure) вместо делегата, презентер стал бы ответственным за две вещи:
 (1) обработку данных
 (2) обновление UI
 Это нарушает SRP и делает код менее гибким.
 */

protocol FeedImageView {
    associatedtype Image
    func display(_ model: FeedImageViewModel<Image>)
}

final class FeedImagePresenter<View: FeedImageView, Image> where View.Image == Image {
    private let view: View // <— сильная ссылка на view
    private let imageTransformer: (Data) -> Image?

    internal init(view: View, imageTransformer: @escaping (Data) -> Image?) {
        self.view = view // <— сильная ссылка может привести к retain cycle
        self.imageTransformer = imageTransformer
    }

    func didStartLoadingImageData(for model: FeedImage) {
        view.display(FeedImageViewModel(
            description: model.description,
            location: model.location,
            image: nil,
            isLoading: true,
            shouldRetry: false))
    }

    private struct InvalidImageDataError: Error {}

    func didFinishLoadingImageData(with data: Data, for model: FeedImage) {
        guard let image = imageTransformer(data) else {
            return didFinishLoadingImageData(with: InvalidImageDataError(), for: model)
        }

        view.display(FeedImageViewModel(
            description: model.description,
            location: model.location,
            image: image,
            isLoading: false,
            shouldRetry: false))
    }

    func didFinishLoadingImageData(with error: Error, for model: FeedImage) {
        view.display(FeedImageViewModel(
            description: model.description,
            location: model.location,
            image: nil,
            isLoading: false,
            shouldRetry: true))
    }
}
