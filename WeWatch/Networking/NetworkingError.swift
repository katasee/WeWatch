//
//  NetworkingError.swift
//  WeWatch
//
//  Created by Anton on 16/04/2025.
//

import Foundation

enum NetworkingError: Error {
    
    case invalidResponse
    case decodingError
    case custom(errorMessage: String)
    case invalidURL
    case invalidStatusCode
}
