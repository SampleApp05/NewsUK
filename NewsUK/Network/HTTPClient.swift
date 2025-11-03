//
//  HTTPClient.swift
//  NewsUK
//
//  Created by Daniel Velikov on 11/1/25.
//

import Foundation

protocol BaseHTTPClient {
    var service: HTTPService { get }
    
    func execute(request: URLRequest) async throws -> Data
    func execute<T: Codable>(request: URLRequest, decoder: JSONDecoder) async throws -> T
}

final class HTTPClient: BaseHTTPClient {
    private static let successStatusRange = Set(200...299)
    
    let service: HTTPService
    
    init(service: HTTPService) {
        self.service = service
    }
    
    // MARK: - Public
    func execute(request: URLRequest) async throws -> Data {
        let (data, response): (Data, URLResponse)
        
        do {
            (data, response) = try await service.execute(request: request)
        } catch {
            throw NetworkError.requestFailed(error)
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        guard Self.successStatusRange.contains(httpResponse.statusCode) else {
            throw NetworkError.statusCode(httpResponse.statusCode)
        }
        
        return data
    }
    
    func execute<T: Codable>(request: URLRequest, decoder: JSONDecoder = .init()) async throws -> T {
        let data = try await execute(request: request)
        
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingFailed(error)
        }
    }
}
