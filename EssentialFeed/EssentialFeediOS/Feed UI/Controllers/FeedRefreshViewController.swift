//
//  FeedRefreshViewController.swift
//  EssentialFeediOS
//
//  Created by Denis Yaremenko on 06.02.2025.
//

import UIKit

/// Could not cast value of type 'EssentialFeediOS.FeedRefreshViewController' (0x101898d60) to 'NSObject' (0x1f052ca18).
/// If you forget to inherit NSObject and your class is using #selector(refresh) they you are done)

final class FeedRefreshViewController: NSObject {
    
    private(set) lazy var view = binded(UIRefreshControl())
    private let viewModel: FeedViewModel
    
    init(viewModel: FeedViewModel) {
        self.viewModel = viewModel
    }
    
    @objc func refresh() {
        viewModel.loadFeed()
    }
    
    private func binded(_ view: UIRefreshControl) -> UIRefreshControl {
        viewModel.onLoadingStateChange = { [weak view] isLoading in
            if isLoading {
                view?.beginRefreshing()
            } else {
                view?.endRefreshing()
            }
        }
        
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return view
    }
}
