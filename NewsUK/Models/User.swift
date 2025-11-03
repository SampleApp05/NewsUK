//
//  User.swift
//  NewsUK
//
//  Created by Daniel Velikov on 11/2/25.
//

import Foundation

nonisolated struct User: Hashable, Sendable {
    let id: String
    let name: String
    let reputation: String
    let imageURL: URL
    let isFollowing: Bool
}
