//
//  HTTPClientTests.swift
//  NewsUK
//
//  Created by Daniel Velikov on 11/1/25.
//

import Testing
import Foundation
@testable import NewsUK

struct TestData: Codable, Equatable {
    let value: String
}

struct InvalidData: Codable {}

struct RESTClientTests {
    let service: MockHTTPService
    let client: HTTPClient

    init() {
        service = MockHTTPService()
        client = HTTPClient(service: service)
    }

    @Test
    func testExecute_SuccessfulResponse_ReturnsDecodedData() async throws {
        let expected = TestData(value: "hello")
        let response = RequestResponse(status: 200, message: nil, data: expected)
        service.result = .success(try! JSONEncoder().encode(response))

        let request = URLRequest(url: URL(string: "https://test.com")!)
        let result: TestData = try await client.execute(request: request)

        #expect(result.value == expected.value)
    }

    @Test
    func testExecute_InvalidStatusCode_ThrowsStatusCodeError() async {
        service.httpResponse = HTTPURLResponse(
            url: URL(string: "https://test.com")!,
            statusCode: 404,
            httpVersion: nil,
            headerFields: nil
        )!

        let request = URLRequest(url: URL(string: "https://test.com")!)
        await #expect {
            _ = try await client.execute(request: request) as TestData
        } throws: { (error) in
            guard let networkError = error as? NetworkError,
                  case .statusCode(404) = networkError else {
                return false }
            return true
        }
    }
    
    @Test
    func testExecute_InvalidData_ThrowsDecodingError() async {
        let invalidData = InvalidData()
        let response = RequestResponse(status: 200, message: nil, data: invalidData)
        service.result = .success(try! JSONEncoder().encode(response))
        
        let request = URLRequest(url: URL(string: "https://test.com")!)
        await #expect {
            _ = try await client.execute(request: request) as TestData
        } throws: { (error) in
            guard case .decodingFailed = (error as? NetworkError) else {
                return false
            }
            return true
        }
    }
    
    @Test
    func testExecute_TransportError_MapsToRequestFailed() async {
        service.result = .failure(URLError(.notConnectedToInternet))

        let request = URLRequest(url: URL(string: "https://test.com")!)
        await #expect {
            _ = try await client.execute(request: request) as TestData
        } throws: { error in
            guard case .requestFailed(let networkError) = (error as? NetworkError),
                  (networkError as? URLError)?.code == .notConnectedToInternet else {
                return false
            }
            return true
        }
    }
    
    final class NonHTTPResponseService: HTTPService {
        func execute(request: URLRequest) async throws -> (Data, URLResponse) {
            let url = request.url ?? URL(string: "https://example.com")!
            let response = URLResponse(url: url, mimeType: "application/json", expectedContentLength: 2, textEncodingName: nil)
            return (Data("{}".utf8), response)
        }
    }
    
    @Test
    func testExecute_NonHTTPURLResponse_ThrowsInvalidResponse() async {
        service.plainResponse = .init(
            url: URL(string: "https://test.com")!,
            mimeType: "application/json",
            expectedContentLength: 2,
            textEncodingName: nil
        )
        
        let request = URLRequest(url: URL(string: "https://test.com")!)
        
        await #expect {
            _ = try await client.execute(request: request) as TestData
        } throws: { error in
            guard case .invalidResponse = (error as? NetworkError) else { return false }
            return true
        }
    }
    
    @Test
    func testExecute_MalformedJSON_ThrowsDecodingFailed() async {
        service.result = .success(Data("{\"garbage\":true}".utf8))
        
        let request = URLRequest(url: URL(string: "https://test.com")!)
        await #expect {
            _ = try await client.execute(request: request) as TestData
        } throws: { error in
            guard case .decodingFailed = (error as? NetworkError) else { return false }
            return true
        }
    }
    
    @Test
    func testExecute_InternalAPIErrorInEnvelope_ThrowsRequestErrorInternalAPI() async {
        let response = RequestResponse<TestData>(status: 500, message: "Server error", data: nil)
        service.result = .success(try! JSONEncoder().encode(response))
        
        let request = URLRequest(url: URL(string: "https://test.com")!)
        await #expect {
            _ = try await client.execute(request: request) as TestData
        } throws: { error in
            guard let requestError = error as? RequestError,
                  case .internalAPI(code: 500, message: let message) = requestError,
                  message == "Server error" else {
                return false
            }
            return true
        }
    }
    
    @Test
    func testExecute_MissingDataInEnvelope_ThrowsRequestErrorMissingData() async {
        let response = RequestResponse<TestData>(status: 200, message: nil, data: nil)
        service.result = .success(try! JSONEncoder().encode(response))
        
        let request = URLRequest(url: URL(string: "https://test.com")!)
        await #expect {
            _ = try await client.execute(request: request) as TestData
        } throws: { error in
            guard let requestError = error as? RequestError,
                  case .missingData = requestError else {
                return false
            }
            return true
        }
    }
}
