//
//  FollowListServiceTests.swift
//  NewsUK
//
//  Created by Daniel Velikov on 11/3/25.
//

import Testing
import Foundation
@testable import NewsUK

struct FollowListServiceTests {
    @Test
    func fetchFollowListEmpty() {
        let service = FollowListService(key: "1")
        service.fetchFollowList()
        #expect(service.followList.isEmpty == true)
    }
    
    @Test
    func follow() {
        let service = FollowListService(key: "2")
        service.follow(userId: "123")
        
        #expect(service.followList.count == 1)
        #expect(service.isFollowing(userId: "123") == true)
        #expect(service.isFollowing(userId: "1235") == false)
    }
    
    @Test
    func unfollow() {
        let service = FollowListService(key: "3")
        service.follow(userId: "123")
        
        #expect(service.isFollowing(userId: "123") == true)
        
        service.unfollow(userId: "123")
        
        #expect(service.isFollowing(userId: "123") == false)
        #expect(service.followList.isEmpty == true)
    }
    
    @Test
    func followSameAccount() {
        let service = FollowListService(key: "4")
        service.follow(userId: "123")
        service.follow(userId: "123")
        service.follow(userId: "123")
        service.follow(userId: "123")
        
        #expect(service.followList.count == 1)
        #expect(service.isFollowing(userId: "123") == true)
    }
    
    @Test
    func unfollowInvalidAccount() {
        let service = FollowListService(key: "4")
        service.follow(userId: "123")
        
        service.unfollow(userId: "1245")
        #expect(service.followList.count == 1)
        
        #expect(service.isFollowing(userId: "123") == true)
        #expect(service.isFollowing(userId: "1245") == false)
    }
    
    @Test
    func unfollowAll() {
        let service = FollowListService(key: "5")
        
        service.follow(userId: "1")
        service.follow(userId: "2")
        service.follow(userId: "3")
        
        #expect(service.followList.count == 3)
        
        service.unfollowAll()
        #expect(service.followList.isEmpty == true)
    }
}
