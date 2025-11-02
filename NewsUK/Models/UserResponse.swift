//
//  UserResponse.swift
//  NewsUK
//
//  Created by Daniel Velikov on 11/2/25.
//

import Foundation

struct UserResponse: Codable, Equatable {
    let userId: String
    let profileImage: URL
    let displayName: String
    let reputation: Int
}

struct UsersResponse: Codable, Equatable {
    let items: [UserResponse]
}
