//
//  FeedImageCellController.swift
//  EssentialFeediOS
//
//  Created by Denis Yaremenko on 05.02.2025.
//

import UIKit
import EssentialFeed

public protocol FeedImageCellControllerDelegate {
    func didRequestImage()
    func didCancelImageRequest()
}

public final class FeedImageCellController: FeedImageView {
    
    private let delegate: FeedImageCellControllerDelegate
    private var cell: FeedImageCell?
    
   public init(delegate: FeedImageCellControllerDelegate) {
        self.delegate = delegate
    }
    
    // MARK: - Methods
    
     func view(in tableView: UITableView) -> UITableViewCell {
        cell = tableView.dequeueReusableCell()
        delegate.didRequestImage()
        return cell!
    }
    
     func preload() {
        delegate.didRequestImage()
    }
    
     func cancelLoad() {
        releaseCellForReuse()
        delegate.didCancelImageRequest()
    }
    
    public func display(_ viewModel: FeedImageViewModel<UIImage>) {
        cell?.locationContainer.isHidden = !viewModel.hasLocation
        cell?.locationLabel.text = viewModel.location
        cell?.descriptionLabel.text = viewModel.description
        
        cell?.feedImageView.setImageAnimated(viewModel.image)
        
        cell?.feedImageContainer.isShimmering = viewModel.isLoading
        cell?.feedImageRetryButton.isHidden = !viewModel.shouldRetry
        cell?.onRetry = delegate.didRequestImage
        
        /// accessibilityIdentifier for EssentialAppUIAcceptanceTests
        cell?.accessibilityIdentifier = "feed-image-cell"
        cell?.feedImageView.accessibilityIdentifier = "feed-image-view"
        
        cell?.onReuse = { [weak self] in
            self?.releaseCellForReuse()
        }
    }
    
    /*
     1. Оптимизация повторного использования ячеек (cell reuse):
     На iOS 15+ таблицы могут использовать кэшированные ячейки, чтобы избежать их повторного создания при быстром прокручивании. Когда ячейка прокручивается, она может быть удалена, но не пересоздаваться, если уже существует кэшированная версия для этого индекса. Это улучшает производительность, так как создание новых ячеек требует больше времени.
     Однако, если кэшированная ячейка не будет отображена (например, если она не попадет в видимую область экрана), могут возникать проблемы с обновлением содержимого ячейки, например, изображения.
     
     2. Проблема с отображением контента в ячейке:
     В старых версиях iOS, при удалении ячейки с экрана (didEndDisplayingCell), ресурсы, такие как изображения, могли быть отменены. В новых версиях, если ячейка кэшируется и больше не пересоздается, эти ресурсы могут не быть отменены должным образом.
     Когда ячейка возвращается на экран (например, при прокрутке таблицы вверх), данные (например, изображения) могут не быть перезагружены, если их не запросить снова через willDisplayCell, что приводит к несоответствию содержимого.
     
     3. Решение:
     Для iOS 15+ необходимо обрабатывать эти случаи: при завершении отображения ячейки нужно отменить запросы на загрузку (в didEndDisplayingCell), а при повторном отображении ячейки (в willDisplayCell) — заново инициировать загрузку данных, таких как изображения.
     
     4. Решение для кэшированных ячеек:
     В некоторых случаях ячейка может быть создана заранее с помощью метода cellForRowAtIndexPath, но если эта ячейка не попадает на экран, то не будет вызвано соответствующее обновление (например, отмена запросов в didEndDisplaying).
     Это может привести к ошибкам, когда запросы на изображения для ячеек, которые не отображаются, не отменяются вовремя, и при повторном использовании ячейки может загрузиться неправильное изображение для неправильного индекса.
     Таким образом, на iOS 15+ необходимо учитывать эти изменения в жизненном цикле ячеек, чтобы избежать проблем с загрузкой данных для повторно используемых ячеек.
     */
    
    /*
     Ensure previous cells' prepareForReuse doesn't affect new cells by removing the onReuse closure reference when releasing the cell for reuse.
     Every time we update the table view state, existing cells can be reused for different index paths, where they'll be managed by different cell controllers - so we need to remove all references to the previous cell controllers when releasing the cell for reuse. Since the `onReuse` closure references the cell controller via `self`, we need to set `onReuse` to `nil` when releasing the cell for reuse by another cell controller. This way, we ensure there are no references to the cell controller so there will be no side effects.
     */
    func releaseCellForReuse() {
        cell?.onReuse = nil
        cell = nil
    }
}
