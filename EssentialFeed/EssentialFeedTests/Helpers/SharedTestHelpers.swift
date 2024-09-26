//
//  SharedTestHelpers.swift
//  EssentialFeed
//
//  Created by Denis Yaremenko on 28.01.2025.
//

import Foundation


func anyURL() -> URL {
    URL(string: "http://any-url.com")!
}

func anyData() -> Data {
    Data("any_data".utf8)
}

func anyNSError() -> NSError {
    NSError(domain: "any error", code: 1)
}
