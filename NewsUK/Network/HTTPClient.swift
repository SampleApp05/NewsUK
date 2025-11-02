//
//  HTTPClient.swift
//  NewsUK
//
//  Created by Daniel Velikov on 11/1/25.
//

import Foundation

protocol BaseHTTPClient {
    var service: HTTPService { get }
    func execute<T: Codable>(request: URLRequest) async throws -> T
}

final class HTTPClient: BaseHTTPClient {
    private static let successStatusRange = Set(200...299)
    
    let service: HTTPService
    
    init(service: HTTPService) {
        self.service = service
    }
    
    // MARK: - Public
    func execute<T: Codable>(request: URLRequest) async throws -> T {
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
        
        let apiResponse: RequestResponse<T>
        do {
            apiResponse = try JSONDecoder().decode(RequestResponse<T>.self, from: data)
        } catch {
            throw NetworkError.decodingFailed(error)
        }
        
        guard Self.successStatusRange.contains(apiResponse.status) else {
            throw RequestError.internalAPI(code: apiResponse.status, message: apiResponse.message)
        }
        
        guard let responseData = apiResponse.data else {
            throw RequestError.missingData
        }
        
        return responseData
    }
}
