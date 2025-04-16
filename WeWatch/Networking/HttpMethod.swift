//
//  HttpMethod.swift
//  WeWatch
//
//  Created by Anton on 16/04/2025.
//

import Foundation

internal enum HttpMethod {
    
    case get([URLQueryItem])
    case post(Data?)
    
    internal var name: String {
        switch self{
        case .get:
            return "GET"
        case .post:
            return "POST"
        }
    }
}
