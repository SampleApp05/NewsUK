//
//  UsersViewModelTests.swift
//  NewsUK
//
//  Created by Daniel Velikov on 11/2/25.
//

import Testing
import Foundation
@testable import NewsUK

@MainActor
struct UsersViewModelTests {
    let service: MockHTTPService
    let client: HTTPClient
    let viewModel: UsersViewModel
    let followService: MockFollowService

    init() {
        service = MockHTTPService()
        client = HTTPClient(service: service)
        followService = .init()
        viewModel = .init(
            networkService: client,
            decoder: .snakeCase,
            followService: followService
        )
    }
    
    @Test
    func testFetchUsers() async throws {
        let expected = UsersResponse(
            items: [
                .init(
                    userId: "1",
                    profileImage: .init(string: "123")!,
                    displayName: "test",
                    reputation: 100
                )
            ]
        )
        
        let response = RequestResponse(status: 200, message: nil, data: expected)
        
        let data = try JSONEncoder().encode(response)
        service.result = .success(data)
        
        let users = try await viewModel.fetchUsers(from: "https://example.com/users")
        #expect(users == expected)
    }
    
    @Test
    func testFetchUsers_InvalidData() async throws {
        let response = RequestResponse(status: 200, message: nil, data: Data())
        
        let data = try JSONEncoder().encode(response)
        service.result = .success(data)
        
        await #expect {
            _ = try await viewModel.fetchUsers(from: "https://example.com/users")
        } throws: { error in
            guard case .decodingFailed = (error as? NetworkError) else {
                return false
            }
            return true
        }
    }
    
    @Test
    func testFetchUsers_InvalidURL() async throws {
        service.result = .failure(NetworkError.invalidURL)
        
        await #expect {
            _ = try await viewModel.fetchUsers(from: "httfsp://[invalid-url]")
        } throws: { error in
            guard case .invalidURL = (error as? NetworkError) else {
                return false
            }
            return true
        }
    }
    
    @Test
    func testFollow() {
        let target = "test"
        followService.followList = ["1", "2"]
        #expect(viewModel.isFollowing(userId: target) == false)
        
        viewModel.followService.follow(userId: target)
        #expect(viewModel.isFollowing(userId: target) == true)
        
        viewModel.unfollow(userId: target)
        #expect(viewModel.isFollowing(userId: target) == false)
    }
}
