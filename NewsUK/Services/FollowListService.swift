//
//  FollowListService.swift
//  NewsUK
//
//  Created by Daniel Velikov on 11/2/25.
//

import Foundation

protocol BaseFollowListService: AnyObject {
    func isFollowing(userId: String) -> Bool
    func follow(userId: String) -> Void
    func unfollow(userId: String) -> Void
}

final class FollowListService: BaseFollowListService {
    private static let key: String = "followList"
    private var followList: Set<String> = []
    
    // MARK: - Private
    private func fetchFollowList() {
        let list = UserDefaults.standard.stringArray(forKey: Self.key) ?? []
        followList = Set(list)
    }
    
    private func storeFollowList() {
        UserDefaults.standard.set(Array(followList), forKey: Self.key)
    }
    
    // MARK: - Public
    func isFollowing(userId: String) -> Bool {
        followList.contains(userId)
    }
    
    func follow(userId: String) {
        followList.insert(userId)
        storeFollowList()
    }
    
    func unfollow(userId: String) {
        followList.remove(userId)
        storeFollowList()
    }
}
