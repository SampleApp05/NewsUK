//
//  BaseUsersViewModel.swift
//  NewsUK
//
//  Created by Daniel Velikov on 11/2/25.
//

import UIKit

protocol BaseUsersViewModel: AnyObject {
    var networkService: BaseHTTPClient { get }
    var decoder: JSONDecoder { get }
    var followService: BaseFollowListService { get }
    var snapshotData: [User] { get }
    
    func fetchUsers(from source: String) async throws
    func fetchUserImage(for index: Int) -> Task<UIImage?, Never>?
    func cancellImageTask(for index: Int)
    func isFollowing(userId: String) -> Bool
    func follow(userId: String)
    func unfollow(userId: String)
    func didTapUserActionButton(userId: String)
    func fetchDataShapshot() -> [User]
}

// http://api.stackexchange.com/2.2/users?page=1&pagesize=20&order=desc&sort=reputation&site=stackoverflow
final class UsersViewModel: BaseUsersViewModel {
    private var imageTasks: [Int: Task<UIImage?, Never>] = [:]
    private(set) var snapshotData: [User] = []
    
    let networkService: BaseHTTPClient
    let decoder: JSONDecoder
    let followService: BaseFollowListService
    
    init(
        networkService: BaseHTTPClient,
        decoder: JSONDecoder,
        followService: BaseFollowListService
    ) {
        self.networkService = networkService
        self.decoder = decoder
        self.followService = followService
    }
    
    // MARK: - Private
    private func validateSource(_ url: URL) -> Bool {
        guard let scheme = url.scheme, ["http", "https"].contains(scheme.lowercased()) else {
            return false
        }
        
        return true
    }
    
    // MARK: - Public
    func fetchUsers(from source: String) async throws {
        guard let url = URL(string: source), validateSource(url) else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let data: UsersResponse = try await networkService.execute(request: request, decoder: decoder)
        
        snapshotData = data.items.map {
            let id = String($0.userId)
            
            return .init(
                id: id,
                name: $0.displayName,
                reputation: String($0.reputation),
                imageURL: $0.profileImage,
                isFollowing: isFollowing(userId: id)
            )
        }
    }
    
    func fetchUserImage(for index: Int) -> Task<UIImage?, Never>? {
        guard index >= 0, index < snapshotData.count else {
            return nil
        }
        
        if let existingTask = imageTasks[index], existingTask.isCancelled == false {
            return existingTask
        }
        
        let task: Task<UIImage?, Never> = Task { [weak self] in
            guard let self else {
                return nil
            }
            
            var request = URLRequest(url: snapshotData[index].imageURL)
            request.httpMethod = "GET"
            
            guard let imageData = try? await networkService.execute(request: request) else {
                return nil
            }
            
            return .init(data: imageData)
        }
        
        imageTasks[index] = task
        return task
    }
    
    func cancellImageTask(for index: Int) {
        imageTasks[index]?.cancel()
        imageTasks[index] = nil
    }
    
    func isFollowing(userId: String) -> Bool {
        followService.isFollowing(userId: userId)
    }
    
    func follow(userId: String) {
        followService.follow(userId: userId)
    }
    
    func unfollow(userId: String) {
        followService.unfollow(userId: userId)
    }
    
    func didTapUserActionButton(userId: String) {
        let index = snapshotData.firstIndex {
            $0.id == userId
        }
        
        guard let index else {
            return
        }
        
        if isFollowing(userId: userId) {
            unfollow(userId: userId)
        } else {
            follow(userId: userId)
        }
        
        let user = snapshotData[index]
        
        snapshotData.replaceSubrange(
            index...index,
            with: [
                .init(
                    id: user.id,
                    name: user.name,
                    reputation: user.reputation,
                    imageURL: user.imageURL,
                    isFollowing: isFollowing(userId: userId)
                )
            ]
        )
    }
    
    func fetchDataShapshot() -> [User] {
        snapshotData
    }
}
