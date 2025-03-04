//
//  FeedItemsMapperTests.swift
//  EssentialFeedTests
//
//  Created by Denis Yaremenko on 18.01.2025.
//

import XCTest
import EssentialFeed

class FeedItemsMapperTests: XCTestCase {

    func test_map_throwsErrorOnNon200HTTPResponse() throws {
        let samples = [199, 201, 300, 400, 500]
        let data = makeItemsJSON([])

        try samples.forEach { code in
            let response = HTTPURLResponse(statusCode: code)
            XCTAssertThrowsError(try FeedItemsMapper.map(data, from: response))
        }
    }
    
    func test_map_throwsErrorOn200HTTPResponseWithInvalidData() throws {
            let data = Data("invalid_json".utf8)
        
        let response = HTTPURLResponse(statusCode: 200)
        XCTAssertThrowsError(try FeedItemsMapper.map(data, from: response))
    }
    
    func test_map_throwsNoItemsOn200HTTPResponseWithEmptyData() throws {
        let emtpyData = makeItemsJSON([])
        
        let response = HTTPURLResponse(statusCode: 200)
        let result = try FeedItemsMapper.map(emtpyData, from: response)
        
        XCTAssertEqual(result, [])
    }
    
    func test_map_deliversItemsOn200HTTPResponseWithValidData() throws {
        
        let item1 = makeItem(
            id: UUID(),
            imageURL: URL(string: "https://someurl.com")!
        )
        
        let item2 = makeItem(
            id: UUID(),
            description: "a description",
            location: "a location",
            imageURL: URL(string: "https://someanotherurl.com")!
        )
        
        let json = makeItemsJSON([item1.json, item2.json])
        let response = HTTPURLResponse(statusCode: 200)
        let result = try FeedItemsMapper.map(json, from: response)
        
        XCTAssertEqual(result, [item1.item, item2.item])
    }

    // MARK: - Helpers
    
    private func makeItem(
        id: UUID,
        description: String? = nil,
        location: String? = nil,
        imageURL: URL
    ) -> (item: FeedImage, json: [String : Any]) {
        let item = FeedImage(id: id, description: description, location: location, url: imageURL)
        let json = [
            "id" : id.uuidString,
            "description" : description,
            "location" : location,
            "image" : imageURL.absoluteString
        ].compactMapValues { $0 }
        
        return (item, json)
    }
    
    private func makeItemsJSON(_ items: [[String: Any]]) -> Data {
        let json = [ "items" : items ]
        return try! JSONSerialization.data(withJSONObject: json)
    }
}

