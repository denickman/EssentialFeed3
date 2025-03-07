//
//  ImageCommentCellController.swift
//  EssentialFeediOS
//
//  Created by Denis Yaremenko on 06.03.2025.
//

import UIKit
import EssentialFeed

// if you are implementing UIKit protocols you have to inherit your class from NSObject

public class ImageCommentCellController: NSObject, CellController {
    
    private let model: ImageCommentViewModel
    
    public init(model: ImageCommentViewModel) {
        self.model = model
    }
    
    // MARK: - CellController
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ImageCommentCell = tableView.dequeueReusableCell()
        cell.messageLabel.text = model.message
        cell.usernameLabel.text = model.username
        cell.dateLabel.text = model.date
        return cell
    }
    
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        
    }
    
}
