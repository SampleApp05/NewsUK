//
//  HTTPService.swift
//  NewsUK
//
//  Created by Daniel Velikov on 11/1/25.
//

import Foundation

enum NetworkError: Error{
    case invalidURL
    case requestFailed(Error)
    case invalidResponse
    case statusCode(Int)
    case decodingFailed(Error)
}

protocol HTTPService {
    func execute(request: URLRequest) async throws -> (Data, URLResponse)
}

extension URLSession: HTTPService {
    func execute(request: URLRequest) async throws -> (Data, URLResponse) {
        try await data(for: request)
    }
}
