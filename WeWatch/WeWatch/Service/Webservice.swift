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
    case custom (errorMessage: String)
}

struct LoginRequestBody: Encodable {
    let apikey: String
    let pin: String
}

struct LoginResponse: Codable {
    let status: String
    let data: LoginData?
}

struct LoginData: Codable {
    let token: String?
}

enum  HttpMethod {
    case get([URLQueryItem])
    case post(Data?)
    
    var name: String {
        switch self{
        case .get:
            return "GET"
        case .post:
            return "POST"
        }
    }
}

struct Resource<T: Codable> {
    let url: URL
    var method: HttpMethod = .get([])
}

class Webservice {
    
    func call <T: Codable>(_ resource: Resource<T>) async throws -> T {
        var request = URLRequest(url: resource.url)
        
        switch resource.method {
        case .post(let data):
            request.httpMethod = resource.method.name
            request.httpBody = data
        case .get(let queryItems):
            var components = URLComponents(url: resource.url, resolvingAgainstBaseURL: false)
            components?.queryItems = queryItems
            guard let url = components?.url else {
                throw AuthenticationError.invalidCredentials
            }
            request = URLRequest(url: url)
        }
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = ["Content-Type": "application/json"]
        let session = URLSession(configuration: configuration)
        
        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
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
