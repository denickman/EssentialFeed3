//
//  CellController.swift
//  EssentialFeediOS
//
//  Created by Denis Yaremenko on 07.03.2025.
//

import UIKit

// instead of using custom protocol CellController we use this typealias because we can get all of the
// required logic form these table view data source / delegate methods


/// #Option 1
//public typealias CellController = UITableViewDataSource & UITableViewDelegate & UITableViewDataSourcePrefetching


/// #Option 2
// delegate, prefetching - is not mandatory
//public typealias CellController = (
//    dataSource: UITableViewDataSource,
//    delegate: UITableViewDelegate?,
//    dataSourcePrefetching: UITableViewDataSourcePrefetching?
//)


/// #Option 3
// prfer a struct better because we can use differnt inits here
public struct CellController {
    let dataSource: UITableViewDataSource
    let delegate: UITableViewDelegate?
    let dataSourcePrefetching: UITableViewDataSourcePrefetching?
    
    public init(_ dataSource: UITableViewDataSource & UITableViewDelegate & UITableViewDataSourcePrefetching) {
        self.dataSource = dataSource
        self.delegate = dataSource
        self.dataSourcePrefetching = dataSource
    }
    
    // second convenience init
    public init(_ dataSource: UITableViewDataSource) {
        self.dataSource = dataSource
        self.delegate = nil
        self.dataSourcePrefetching = nil
    }
}

