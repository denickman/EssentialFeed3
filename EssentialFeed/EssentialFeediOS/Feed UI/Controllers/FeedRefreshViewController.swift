//
//  FeedRefreshViewController.swift
//  EssentialFeediOS
//
//  Created by Denis Yaremenko on 06.02.2025.
//

import UIKit

protocol FeedRefreshviewControllerDelegate {
    func didRequestFeedRefresh()
}

/// Could not cast value of type 'EssentialFeediOS.FeedRefreshViewController' (0x101898d60) to 'NSObject' (0x1f052ca18).
/// If you forget to inherit NSObject and your class is using #selector(refresh) they you are done)

final class FeedRefreshViewController: NSObject, LoadingView {

    private(set) lazy var view = loadView()
    private let delegate: FeedRefreshviewControllerDelegate
    
    init(delegate: FeedRefreshviewControllerDelegate) {
        self.delegate = delegate
    }
    
    @objc func refresh() {
        delegate.didRequestFeedRefresh()
    }
    
    private func loadView( ) -> UIRefreshControl {
        let view = UIRefreshControl()
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return view
    }
    
    func display(_ viewModel: FeedLoadingviewModel) {
        if viewModel.isLoading {
            view.beginRefreshing()
        } else {
            view.endRefreshing()
        }
    }

}
