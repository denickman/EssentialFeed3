//
//  Copyright © Essential Developer. All rights reserved.
//

import Foundation

/*
public enum LoadFeedResult {
	case success([FeedImage])
	case failure(Error)
}
*/
/// same as Result<[FeedImage], Error>

public protocol FeedLoader {
    typealias Result = Swift.Result<[FeedImage], Error>
	func load(completion: @escaping (Result) -> Void)
}
