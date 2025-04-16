//
//  WebService.swift
//  WeWatch
//
//  Created by Anton on 30/11/2024.
//

import Foundation

internal final class WebService {
    
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
                throw NetworkingError.invalidURL
            }
            request = URLRequest(url: url)
        }
        
        let configuration: URLSessionConfiguration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = ["Content-Type": "application/json"]
        let session: URLSession = URLSession(configuration: configuration)
        if let token = resource.token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        let (data, response) = try await session.data(for: request)
        guard let response: HTTPURLResponse = response as? HTTPURLResponse else {
            throw NetworkingError.invalidResponse
        }
        guard response.statusCode == 200 else {
            throw NetworkingError.invalidStatusCode
        }
        guard let result = try? JSONDecoder().decode(T.self, from: data) else {
            throw NetworkingError.decodingError
        }
        return result
    }
}
