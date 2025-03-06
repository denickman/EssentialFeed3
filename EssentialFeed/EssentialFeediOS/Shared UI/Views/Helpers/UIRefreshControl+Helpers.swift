//
//  UIRefreshControl+Helpers.swift
//  EssentialFeediOS
//
//  Created by Denis Yaremenko on 11.02.2025.
//
    
import UIKit

extension UIRefreshControl {
    func update(isRefreshing: Bool) {
        isRefreshing ? beginRefreshing() : endRefreshing()
    }
}
