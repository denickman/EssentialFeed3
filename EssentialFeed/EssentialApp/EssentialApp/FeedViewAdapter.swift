//
//  FeedViewAdapter.swift
//  EssentialFeediOS
//
//  Created by Denis Yaremenko on 10.02.2025.
//

import UIKit
import EssentialFeed
import EssentialFeediOS

final class FeedViewAdapter: ResourceView {
    
    private weak var controller: ListViewController? // prevent retain cycle
    private let imageLoader: (URL) -> FeedImageDataLoader.Publisher
    private let selection: (FeedImage) -> Void
    private let currentFeed: [FeedImage: CellController]
    
    private typealias ImageDataPresentationAdapter = LoadResourcePresentationAdapter<Data, WeakRefVirtualProxy<FeedImageCellController>>
    
    private typealias LoadMorePresentationAdapter = LoadResourcePresentationAdapter<Paginated<FeedImage>, FeedViewAdapter>

    init(
        currentFeed: [FeedImage: CellController] = [:],
        controller: ListViewController,
        imageLoader: @escaping (URL) -> FeedImageDataLoader.Publisher,
        selection: @escaping (FeedImage) -> Void
    ) {
        self.currentFeed = currentFeed
        self.controller = controller
        self.imageLoader = imageLoader
        self.selection = selection
    }
    
    func display(_ viewModel: Paginated<FeedImage>) {
        
        guard let controller = controller else { return }
        
        var currentFeed = self.currentFeed
        
        let feedSection: [CellController] = viewModel.items.map { model in
            if let ctrl = currentFeed[model] {
                // if exist , do not need to re-create ctrl once again to prevent extra loading feed image process
                return ctrl
            }
            
            let adapter = ImageDataPresentationAdapter(loader: { [imageLoader] in
                // partial application of a function
                // adapting completion with params (url) to compeltion with no params ()
                imageLoader(model.url)
            })
            
            let view = FeedImageCellController(
                viewModel: FeedImagePresenter.map(model),
                delegate: adapter,
                selection: { [selection] in
                    selection(model)
                })
            
            adapter.presenter = LoadResourcePresenter(
                resourceView: WeakRefVirtualProxy(view),
                loadingView: WeakRefVirtualProxy(view),
                errorView: WeakRefVirtualProxy(view),
                mapper: UIImage.tryMake // data -> UIImage
            )
            
            /// since `model` is hashable and `id` is AnyHashable we can apply code like this
            let controller = CellController(id: model, view) // data source, delegate, prefetching
            currentFeed[model] = controller
            return controller
        }
        
        // Try to create and load a new page
        guard let loadMorePublisher = viewModel.loadMorePublisher else {
            controller.display(feedSection)
            return
        }
        
        let loadMoreAdapter = LoadMorePresentationAdapter(loader: loadMorePublisher)
        let loadMore = LoadMoreCellController(callback: loadMoreAdapter.loadResource)
        
        let fva = FeedViewAdapter(
            currentFeed: currentFeed,
            controller: controller,
            imageLoader: imageLoader,
            selection: selection
        )

        loadMoreAdapter.presenter = LoadResourcePresenter(
            resourceView: fva, // self
            loadingView: WeakRefVirtualProxy(loadMore),
            errorView: WeakRefVirtualProxy(loadMore),
            mapper: { $0 }
        )
 
        let loadMoreSection = [CellController(id: UUID(), loadMore)] // a section for load more cell ctrl with only 1 item

        controller.display(feedSection, loadMoreSection)
    }
}

extension UIImage {
    struct InvalidImageData: Error {}

    static func tryMake(data: Data) throws -> UIImage {
        guard let image = UIImage(data: data) else {
            throw InvalidImageData()
        }
        return image
    }
}

