//
//  MockFollowService.swift
//  NewsUK
//
//  Created by Daniel Velikov on 11/2/25.
//

import Foundation
@testable import NewsUK

final class MockFollowService: BaseFollowListService {
    var followList: Set<String> = []
    
    func isFollowing(userId: String) -> Bool {
        followList.contains(userId)
    }
    
    func follow(userId: String) {
        followList.insert(userId)
    }
    
    func unfollow(userId: String) {
        followList.remove(userId)
    }
}
