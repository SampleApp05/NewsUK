//
//  RequestResponse.swift
//  NewsUK
//
//  Created by Daniel Velikov on 11/1/25.
//

import Foundation

struct RequestResponse<T: Codable>: Codable {
    let status: Int
    let message: String?
    let data: T?
}

enum RequestError: LocalizedError {
    case missingData
    case internalAPI(code: Int, message: String?)
    
    var errorDescription: String? {
        switch self {
        case .missingData:
            return "Response data is missing"
        case .internalAPI(_, let message):
            return message
        }
    }
}
