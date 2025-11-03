//
//  FollowListService.swift
//  NewsUK
//
//  Created by Daniel Velikov on 11/2/25.
//

import Foundation

protocol BaseFollowListService: AnyObject {
    var followList: Set<String> { get }
    func fetchFollowList()
    func isFollowing(userId: String) -> Bool
    func follow(userId: String) -> Void
    func unfollow(userId: String) -> Void
    func unfollowAll() -> Void
}

final class FollowListService: BaseFollowListService {
    private static let defaultKey: String = "followList"
    private let storageKey: String
    
    private(set) var followList: Set<String> = []
    
    init(key: String? = nil) {
        storageKey = key ?? Self.defaultKey
        fetchFollowList()
    }
    
    // MARK: - Private
    private func storeFollowList() {
        UserDefaults.standard.set(Array(followList), forKey: storageKey)
    }
    
    // MARK: - Public
    func fetchFollowList() {
        let list = UserDefaults.standard.stringArray(forKey: storageKey) ?? []
        followList = Set(list)
    }
    
    // MARK: - Public
    func isFollowing(userId: String) -> Bool {
        followList.contains(userId)
    }
    
    func follow(userId: String) {
        guard isFollowing(userId: userId) == false else { return }
        
        followList.insert(userId)
        storeFollowList()
    }
    
    func unfollow(userId: String) {
        guard isFollowing(userId: userId) == true else { return }
        
        followList.remove(userId)
        storeFollowList()
    }
    
    func unfollowAll() {
        followList = []
        UserDefaults.standard.removeObject(forKey: storageKey)
    }
}
