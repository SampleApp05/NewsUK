//
//  UsersViewModelTests.swift
//  NewsUK
//
//  Created by Daniel Velikov on 11/2/25.
//

import Testing
import Foundation
import UIKit
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
        let expectedUser = UserResponse(
            userId: 1,
            profileImage: .init(string: "123")!,
            displayName: "test",
            reputation: 100
        )
        
        let response = UsersResponse(
            items: [
                expectedUser
            ]
        )
        
        let data = try JSONEncoder().encode(response)
        service.result = .success(data)
        
        try await viewModel.fetchUsers(from: "https://example.com/users")
        let users = viewModel.snapshotData
        
        #expect(users.count == 1)
        let user = users.first!
        
        #expect(user.isFollowing == false)
        #expect(user.id == String(expectedUser.userId))
        #expect(user.imageURL == expectedUser.profileImage)
        #expect(user.name == expectedUser.displayName)
        #expect(user.reputation == String(expectedUser.reputation))
    }
    
    @Test
    func testFetchUsers_InvalidData() async throws {
        let data = try JSONEncoder().encode(Data())
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
        
        viewModel.follow(userId: target)
        #expect(viewModel.isFollowing(userId: target) == true)
        
        viewModel.unfollow(userId: target)
        #expect(viewModel.isFollowing(userId: target) == false)
    }
    
    @Test
    func testFetchUserImage_OutOfBoundsReturnsNil() async throws {
        #expect(viewModel.fetchUserImage(for: -1) == nil)
        #expect(viewModel.fetchUserImage(for: 0) == nil)
        
        let expectedUser = UserResponse(
            userId: 1,
            profileImage: .init(string: "123")!,
            displayName: "test",
            reputation: 100
        )
        
        let response = UsersResponse(
            items: [
                expectedUser
            ]
        )
        
        let data = try JSONEncoder().encode(response)
        service.result = .success(data)
        try await viewModel.fetchUsers(from: "https://api.example.com/users")
        
        #expect(viewModel.fetchUserImage(for: 0) != nil)
        #expect(viewModel.fetchUserImage(for: 1) == nil)
    }
    
    @Test
    func testFetchUserImage_TaskCachingAndImageDecoding() async throws {
        let expectedUser = UserResponse(
            userId: 1,
            profileImage: .init(string: "123")!,
            displayName: "test",
            reputation: 100
        )
        
        let response = UsersResponse(
            items: [
                expectedUser
            ]
        )
        
        let data = try JSONEncoder().encode(response)
        service.result = .success(data)
        try await viewModel.fetchUsers(from: "https://api.example.com/users")
        
        let imageData = UIImage(systemName: "plus")!.pngData()!
        service.result = .success(imageData)
        
        let task1 = viewModel.fetchUserImage(for: 0)
        let task2 = viewModel.fetchUserImage(for: 0)
        
        #expect(task1 != nil)
        #expect(task1 == task2)
        
        let image = await task1!.value
        
        #expect(image != nil)
        #expect(await task2!.value == image)
    }
    
    @Test
    func testFetchUserImage_CancelRemovesFromCacheAndCreatesNewTask() async throws {
        let expectedUser = UserResponse(
            userId: 1,
            profileImage: .init(string: "123")!,
            displayName: "test",
            reputation: 100
        )
        
        let response = UsersResponse(
            items: [
                expectedUser
            ]
        )
        
        let data = try JSONEncoder().encode(response)
        service.result = .success(data)
        try await viewModel.fetchUsers(from: "https://api.example.com/users")
        
        let imageData = UIImage(systemName: "plus")!.pngData()!
        service.result = .success(imageData)
        
        let firstTask = viewModel.fetchUserImage(for: 0)
        #expect(firstTask != nil)
        
        viewModel.cancellImageTask(for: 0)
        #expect(firstTask?.isCancelled == true)
        
        let secondTask = viewModel.fetchUserImage(for: 0)
        #expect(secondTask != nil)
        #expect(firstTask != secondTask)
        
        #expect(firstTask!.isCancelled == true)
        #expect(secondTask!.isCancelled == false)
        
        let image = await secondTask!.value
        #expect(image != nil)
    }
}
