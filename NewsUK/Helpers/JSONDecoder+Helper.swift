//
//  JSONDecoder+Helper.swift
//  NewsUK
//
//  Created by Daniel Velikov on 11/2/25.
//

import Foundation

extension JSONDecoder {
    static var snakeCase: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }
}
