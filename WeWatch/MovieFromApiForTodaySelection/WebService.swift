//
//  WebService.swift
//  WeWatch
//
//  Created by Anton on 05/02/2025.
//

import Foundation

final class WebService {
    
    internal enum KeychainKey {
        static let token: String = "token"
    }
    
    static func getMovie(query: String) async throws -> DomainModels {
        let endpoint: String = "https://api4.thetvdb.com/v4/search?query=\(query)"
        guard let url: URL = .init(string: endpoint) else {
            throw urlError.invalidURL
        }
        let tokenData: Data? = try KeychainManager.getData(key: KeychainKey.token)
        let token: String = .init(decoding: tokenData ?? Data(), as: UTF8.self)
        var request: URLRequest = .init(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        let(data, response) = try await URLSession.shared.data(for: request)
        guard let response: HTTPURLResponse = response as? HTTPURLResponse else {
            throw urlError.invalidResponse
        }
        guard response.statusCode == 200 else {
            throw urlError.invalidStatusCode
        }
        do {
            let decoder: JSONDecoder = .init()
            return try decoder.decode(DomainModels.self, from: data)
        } catch {
            throw urlError.invalidData
        }
    }
    
    enum urlError: Error {
        case invalidURL
        case invalidResponse
        case invalidData
        case invalidStatusCode
    }
}
