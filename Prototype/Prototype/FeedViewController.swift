//
//  FeedViewController.swift
//  Prototype
//
//  Created by Denis Yaremenko on 05.02.2025.
//

import UIKit

class FeedViewController: UITableViewController {
    
    // MARK: - Properties
    
    private var feeds = [FeedImageViewModel]()
    
    // MARK: - Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refresh()
        tableView.setContentOffset(CGPoint(x: 0, y: -tableView.contentInset.top), animated: false)
    }
    
    // MARK: - IBActions
    
    @IBAction func refresh() {
        refreshControl?.beginRefreshing()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: {
            if self.feeds.isEmpty {
                self.feeds = FeedImageViewModel.prototypeFeed
                self.tableView.reloadData()
            }
            self.refreshControl?.endRefreshing()
        })
    }
}

// MARK: - UITableViewDataSource

extension FeedViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feeds.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: FeedImageCell.self), for: indexPath) as! FeedImageCell
        let feed = feeds[indexPath.row]
        cell.configure(with: feed)
        return cell
    }
}

