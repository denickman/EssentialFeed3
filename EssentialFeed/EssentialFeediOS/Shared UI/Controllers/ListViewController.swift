//
//  FeedViewController.swift
//  EssentialFeediOS
//
//  Created by Denis Yaremenko on 06.02.2025.
//

import UIKit
import EssentialFeed

public final class ListViewController: UITableViewController {
    
    // MARK:  - Properties
    
    public var onRefresh: (() -> Void)?
    private(set) public var errorView = ErrorView()
    private var loadingControllers = [IndexPath: CellController]()
    
        // CellController should be Hashable so diffable data source can compare any change to the model, it`s keep track the state for us
    // DDS will try to imply by the estimated row height how many cells it can load ahead of time and load only these cells
    private lazy var dataSource: UITableViewDiffableDataSource<Int, CellController> = {
        .init(tableView: tableView) { tableView, indexPath, controller in
            print("Index path \(indexPath)")
            let ds = controller.dataSource
            return ds.tableView(tableView, cellForRowAt: indexPath)
        }
    }()
    
    // MARK:  - Lifecycle
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = dataSource
        configureErrorView()
        refresh()
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.sizeTableHeaderToFit()
    }
    
    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if previousTraitCollection?.preferredContentSizeCategory != traitCollection.preferredContentSizeCategory {
            tableView.reloadData()
        }
    }
    
    // MARK:  - Methods
    
    public func display(_ cellControllers: [CellController]) {
        var snapshot = NSDiffableDataSourceSnapshot<Int, CellController>() // create an empty snapshot
        snapshot.appendSections([0])
        snapshot.appendItems(cellControllers, toSection: 0)
        
        if #available(iOS 15.0, *) {
            /// Чтобы получить поведение перезагрузки всей таблицы (или коллекции), необходимо использовать метод applySnapshotUsingReloadData(snapshot)
            /// в 15.0 - dataSource.apply(snapshot) всегда выполняет дифф и обновляет только измененные ячейки
            dataSource.applySnapshotUsingReloadData(snapshot)
        } else {
            /// tell ds to apply snapshot, the ds will check what change using the hashable implementation and only update what is necessary
            /// apply(snapshot) - перегрузка всей таблиці
            dataSource.apply(snapshot)
        }
    }
    
    @IBAction private func refresh() {
        onRefresh?()
    }
    
    private func configureErrorView() {
        let container = UIView()
        container.backgroundColor = .clear
        container.addSubview(errorView)
        errorView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate ([
            errorView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            errorView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            errorView.topAnchor.constraint(equalTo: container.topAnchor),
            errorView.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        
        tableView.tableHeaderView = container
        
        errorView.onHide = { [weak self] in
            self?.tableView.beginUpdates()
            self?.tableView.sizeTableHeaderToFit()
            self?.tableView.endUpdates()
        }
    }
}

extension ListViewController: UITableViewDataSourcePrefetching {

    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let delegate = cellController(at: indexPath)?.delegate
        delegate?.tableView?(tableView, didEndDisplaying: cell, forRowAt: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            let dsp = cellController(at: indexPath)?.dataSourcePrefetching
            dsp?.tableView(tableView, prefetchRowsAt: [indexPath])
        }
    }
    
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            let dsp = cellController(at: indexPath)?.dataSourcePrefetching
            dsp?.tableView?(tableView, cancelPrefetchingForRowsAt: [indexPath])
        }
    }
    
    private func cellController(at indexPath: IndexPath) -> CellController? {
        dataSource.itemIdentifier(for: indexPath)
    }

}

extension ListViewController: ResourceLoadingView {
    public func display(_ viewModel: ResourceLoadingViewModel) {
        refreshControl?.update(isRefreshing: viewModel.isLoading)
    }
}

extension ListViewController: ResourceErrorView {
    public func display(_ viewModel: ResourceErrorViewModel) {
        errorView.message = viewModel.message
    }
}


/*
 /// Когда вы вызываете `tableView.reloadData()`, это приводит к повторной загрузке данных в таблице, что включает перерасчет всех видимых ячеек и обновление их на экране. Однако, перед тем как обновить эти ячейки, система вызывает метод делегата `tableView(_:didEndDisplaying:forRowAt:)` для каждой ячейки, которая больше не отображается на экране.

 /// When updating the table model and reloading the table, UIKit calls `didEndDisplayingCell` for each removed cell that was previously visible. Since we're canceling requests in this method, we could be sending messages to the new models or potentially crashing in case the new table model has fewer items than the previous one!
 
 /// This is not a big problem at the moment since items cannot be removed from the feed. But we cannot assume the backend will keep this behavior going further.
 
 */
