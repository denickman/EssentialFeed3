//
//  LoadMoreCellController.swift
//  EssentialFeediOS
//
//  Created by Denis Yaremenko on 24.03.2025.
//

import UIKit
import EssentialFeed

public class LoadMoreCellController: NSObject, UITableViewDataSource {
    
    private let cell = LoadMoreCell()
    private let callback: () -> Void
    private var offsetObserver: NSKeyValueObservation?
    
    public init(callback: @escaping () -> Void) {
        self.callback = callback
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        cell.selectionStyle = .none
       return cell // we do need to reuse, only 1 cell
    }
}

extension LoadMoreCellController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, willDisplay: UITableViewCell, forRowAt indexPath: IndexPath) {
        reloadIfNeeded()
        
      offsetObserver = tableView.observe(\.contentOffset, options: .new) { [weak self] (tableView, value) in
            guard tableView.isDragging else { return }
            print("TV Dragging....")
            self?.reloadIfNeeded()
        }
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        reloadIfNeeded()
    }
    
    public func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        offsetObserver = nil
    }

    private func reloadIfNeeded() {
        guard !cell.isLoading else { return }
        callback()
    }
}

extension LoadMoreCellController: ResourceLoadingView {
    public func display(_ viewModel: ResourceLoadingViewModel) {
        cell.isLoading = viewModel.isLoading
    }
}

extension LoadMoreCellController: ResourceErrorView {
    public func display(_ viewModel: ResourceErrorViewModel) {
        cell.message = viewModel.message
    }
    
    
}
