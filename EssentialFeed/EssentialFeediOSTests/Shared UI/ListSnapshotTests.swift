//
//  ListSnapshotTests.swift
//  EssentialFeediOSTests
//
//  Created by Denis Yaremenko on 06.03.2025.
//

import XCTest
import EssentialFeediOS
@testable import EssentialFeed

/// New snapshot URL: file:///Users/denisyaremenko/Library/Developer/XCTestDevices/47A89C37-DB76-4132-BAFE-D0CCBFFC0190/data/tmp/LIST_WITH_ERROR_MESSAGE_light.png
///  stored snapshot URL: file:///Users/denisyaremenko/Desktop/iOS/Education/2025/Caio%20&%20Mike/EF/EF3/EF3/EssentialFeed/EssentialFeediOSTests/Shared%20UI/snapshots/LIST_WITH_ERROR_MESSAGE_light.png

final class ListSnapshotTests: XCTestCase {
    
    func test_emtpyList() {
        let sut = makeSUT()
        
        sut.display(emptyList())
        
//        record(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "EMPTY_LIST_light")
//        record(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "EMPTY_LIST_dark")
        
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "EMPTY_LIST_light")
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "EMPTY_LIST_dark")
    }
    
    
    func test_listWithErrorMessage() {
        let sut = makeSUT()
        
        sut.display(.error(message: "This is a\nmulti-line\nerror message"))
        
//        record(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "LIST_WITH_ERROR_MESSAGE_light")
//        record(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "LIST_WITH_ERROR_MESSAGE_dark")
        
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "LIST_WITH_ERROR_MESSAGE_light")
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "LIST_WITH_ERROR_MESSAGE_dark")
    }
    
    private func makeSUT() -> ListViewController {
        // since we eliminate errorView from the storyboard, we do not need storyboard anymore
//        let bundle = Bundle(for: ListViewController.self)
//        let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
//        let controller = storyboard.instantiateInitialViewController() as! ListViewController
        
        let controller = ListViewController()
        controller.tableView.separatorStyle = .none // since we remove storyboard we have to set it directly here
        controller.loadViewIfNeeded()
        controller.tableView.showsVerticalScrollIndicator = false
        controller.tableView.showsHorizontalScrollIndicator = false
        
        return controller
    }
    
    private func emptyList() -> [CellController] {
        []
    }

}
