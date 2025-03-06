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

extension HTTPURLResponse {
    convenience init(statusCode: Int) {
        self.init(url: anyURL(), statusCode: statusCode, httpVersion: nil, headerFields: nil)!
    }
}

func makeItemsJSON(_ items: [[String: Any]]) -> Data {
    let json = [ "items" : items ]
    return try! JSONSerialization.data(withJSONObject: json)
}


extension Date {
    func adding(seconds: TimeInterval) -> Date {
        self + seconds
    }
    
    func adding(days: Int, calendar: Calendar = .init(identifier: .gregorian)) -> Date {
        calendar.date(byAdding: .day, value: days, to: self)!
    }
    
    func adding(minutes: Int, calendar: Calendar = .init(identifier: .gregorian)) -> Date {
        calendar.date(byAdding: .minute, value: minutes, to: self)!
    }
}
