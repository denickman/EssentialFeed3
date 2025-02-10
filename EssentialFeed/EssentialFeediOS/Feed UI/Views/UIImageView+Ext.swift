//
//  UIImageView+Ext.swift
//  EssentialFeediOS
//
//  Created by Denis Yaremenko on 10.02.2025.
//

import UIKit

extension UIImageView {
    func setImageAnimated(_ newImage: UIImage?) {
        image = newImage
        
        if newImage != nil {
            alpha = .zero
            UIView.animate(withDuration: 0.25) {
                self.alpha = 1
            }
        }
    }
}

