//
//  FeedViewController.swift
//  EssentialFeediOS
//
//  Created by Denis Yaremenko on 05.02.2025.
//

import UIKit
import EssentialFeed

final public class FeedViewController: UITableViewController {
    
    private var loader: FeedLoader?
    
    /// refresh control is an implementation detail, it would be better to hide it from tests
    
    public convenience init(loader: FeedLoader) {
        self.init()
        self.loader = loader
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
        load()
    }
    
    @objc private func load() {
        refreshControl?.beginRefreshing()
        loader?.load { [weak self] _ in
            self?.refreshControl?.endRefreshing()
        }
    }
    
}
