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
    
    func fetchUsers(from source: String) async throws -> UsersResponse
    func isFollowing(userId: String) -> Bool
    func follow(userId: String)
    func unfollow(userId: String)
}

// http://api.stackexchange.com/2.2/users?page=1&pagesize=20&order=desc&sort=reputation&site=stackoverflow
final class UsersViewModel: BaseUsersViewModel {
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
    func fetchUsers(from source: String) async throws -> UsersResponse {
        guard let url = URL(string: source), validateSource(url) else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        return try await networkService.execute(request: request, decoder: decoder)
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
}
