//
//  UIImage+TestHelpers.swift
//  EssentialFeediOSTests
//
//  Created by Denis Yaremenko on 06.02.2025.
//

import UIKit

extension UIImage {
    /// old version
    //    static func make(withColor color: UIColor) -> UIImage {
    //        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
    //        UIGraphicsBeginImageContext(rect.size)
    //        let context = UIGraphicsGetCurrentContext()!
    //        context.setFillColor(color.cgColor)
    //        context.fill(rect)
    //        let img = UIGraphicsGetImageFromCurrentImageContext()
    //        UIGraphicsEndImageContext()
    //        return img!
    //    }
    
    /// new api
    static func make(withColor color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        return UIGraphicsImageRenderer(size: rect.size, format: format).image { rendererContext in
            color.setFill()
            rendererContext.fill(rect)
        }
    }
}
