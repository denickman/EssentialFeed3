//
//  WeakRefVirtualProxy.swift
//  EssentialFeediOS
//
//  Created by Denis Yaremenko on 10.02.2025.
//

import UIKit
import EssentialFeed
import EssentialFeediOS

/*
 🔹 Оборачивает другой объект (object)
 🔹 Не удерживает его сильно (weak var object: T?)
 🔹 Передает вызовы методу display(_), если объект еще существует
 
 Таким образом, если обернутый объект (object) уничтожится (например, ViewController уходит из памяти), прокси не будет удерживать его в памяти и вызовы методов просто игнорируются.
 */

final class WeakRefVirtualProxy<T: AnyObject> {
    private weak var object: T?

    init(_ object: T) {
        self.object = object
    }
}

extension WeakRefVirtualProxy: FeedLoadingView where T: FeedLoadingView {
    func display(_ viewModel: FeedLoadingViewModel) {
        object?.display(viewModel)
    }
}

extension WeakRefVirtualProxy: FeedImageView where T: FeedImageView, T.Image == UIImage {
    func display(_ model: FeedImageViewModel<UIImage>) {
        object?.display(model)
    }
}

extension WeakRefVirtualProxy: FeedErrorView where T: FeedErrorView {
    func display(_ viewModel: FeedErrorViewModel) {
        object?.display(viewModel)
    }
}
