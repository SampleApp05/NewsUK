//
//  MockHTTPService.swift
//  NewsUKTests
//
//  Created by Daniel Velikov on 11/1/25.
//

import Foundation
@testable import NewsUK

final class MockHTTPService: HTTPService {
    var result: Result<Data, Error>?
    var plainResponse: URLResponse?
    var httpResponse: HTTPURLResponse?
    
    func execute(request: URLRequest) async throws -> (Data, URLResponse) {
        if let httpResponse = httpResponse {
            return (Data(), httpResponse)
        }
        
        if let plainResponse = plainResponse {
            return (Data(), plainResponse)
        }
        
        let resultToReturn: Result<Data, Error>
        
        if let result = result {
            resultToReturn = result
        } else {
            fatalError("No result set")
        }
        
        switch resultToReturn {
        case .success(let data):
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (data, response)
        case .failure(let error):
            throw error
        }
    }
}
