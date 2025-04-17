//
//  Login.swift
//  WeWatch
//
//  Created by Anton on 16/04/2025.
//

import Foundation

internal struct LoginRequestBody: Encodable {
    
    internal let apikey: String
    internal let pin: String
}

internal struct LoginResponse: Codable {
    
    internal let status: String
    internal let data: LoginData?
}

internal struct LoginData: Codable {
    
    internal let token: String?
}
