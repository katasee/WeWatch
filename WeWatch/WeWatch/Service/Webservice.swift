//
//  Webservice.swift
//  WeWatch
//
//  Created by Anton on 30/11/2024.
//

import Foundation

enum AuthenticationError: Error {
    
    case invalidCredentials
    case invalidResponse
    case decodingError
    case custom(errorMessage: String)
}

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

internal enum  HttpMethod {
    
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

internal struct Resource<T: Codable> {
    
    internal let url: URL
    internal var method: HttpMethod = .get([])
}

internal final class Webservice {
    
    internal func call <T: Codable>(_ resource: Resource<T>) async throws -> T {
        var request: URLRequest = URLRequest(url: resource.url)
        
        switch resource.method {
        case .post(let data):
            request.httpMethod = resource.method.name
            request.httpBody = data

        case .get(let queryItems):
            var components: URLComponents? = URLComponents(
                url: resource.url,
                resolvingAgainstBaseURL: false
            )
            components?.queryItems = queryItems
            guard let url = components?.url else {
                throw AuthenticationError.invalidCredentials
            }
            request = URLRequest(url: url)
        }
        
        let configuration: URLSessionConfiguration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = ["Content-Type": "application/json"]
        let session: URLSession = URLSession(configuration: configuration)
        
        let (data, response) = try await session.data(for: request)
        guard let httpResponse: HTTPURLResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200
        else {
            throw AuthenticationError.invalidResponse
        }
        
        guard let result = try? JSONDecoder().decode(T.self, from: data) else {
            throw AuthenticationError.decodingError
        }
        return result
    }
}

extension URL {
    static var loginURL: URL {
        return URL(string: "https://api4.thetvdb.com/v4/login")!
    }
}
