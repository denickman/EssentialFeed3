//
//  UITableView+Ext.swift
//  EssentialFeediOS
//
//  Created by Denis Yaremenko on 10.02.2025.
//

import UIKit
    
extension UITableView {
    func dequeueReusableCell<T: UITableViewCell>() -> T {
        let id = String(describing: T.self)
        return dequeueReusableCell(withIdentifier: id) as! T
    }
}
