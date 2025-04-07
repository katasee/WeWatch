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
    case invalidURL
    case invalidStatusCode
}

enum EndpointResponce: Error {
    
    case dataFromEndpoint
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
    internal let token: String?
}

internal final class Webservice {
    
    internal func call <T: Codable>(_ resource: Resource<T>) async throws -> T {
        var request: URLRequest = URLRequest(url: resource.url)
        print(request)
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
            print(request)
        }
        
        let configuration: URLSessionConfiguration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = ["Content-Type": "application/json"]
        let session: URLSession = URLSession(configuration: configuration)
        if let token = resource.token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        let (data, response) = try await session.data(for: request)
        guard let response: HTTPURLResponse = response as? HTTPURLResponse else {
            throw AuthenticationError.invalidResponse
        }
        print(response.statusCode)
        guard response.statusCode == 200 else {
            throw AuthenticationError.invalidStatusCode
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
    
    static var SearchResponseURL: URL {
        return URL(string: "https://api4.thetvdb.com/v4/search")!
    }
    
    static var GenreResponseURL: URL {
        return URL(string: "https://api4.thetvdb.com/v4/genres")!
    }
}
