//
//  FeedImageCell.swift
//  Prototype
//
//  Created by Denis Yaremenko on 05.02.2025.
//

import UIKit

class FeedImageCell: UITableViewCell {
    
    @IBOutlet private(set) var locationContainer: UIView!
    @IBOutlet private(set) var locationLabel: UILabel!
    @IBOutlet private(set) var feedImageView: UIImageView!
    @IBOutlet private(set) var descriptionLabel: UILabel!
    @IBOutlet private(set) var feedImageContainer: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        feedImageView.alpha = .zero
        feedImageContainer.startShimmering()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        feedImageView.alpha = .zero
        feedImageContainer.startShimmering()
    }
    
    func configure(with feed: FeedImageViewModel) {
        locationLabel.text = feed.location
        locationContainer.isHidden = feed.location == nil
        
        descriptionLabel.text = feed.description
        descriptionLabel.isHidden = feed.description == nil
        
        fadeIn(UIImage(named: feed.imageName))
    }
    
    func fadeIn(_ image: UIImage?) {
        feedImageView.image = image
        
        UIView.animate(
            withDuration: 0.25,
            delay: 1.25,
            options: [],
            animations: {
                self.feedImageView.alpha = 1
            }, completion: { completed in
                if completed {
                    self.feedImageContainer.stopShimmering()
                    
                    self.feedImageView.layer.cornerRadius = 22
                    self.feedImageView.layer.masksToBounds = true
                }
            })
    }
}

