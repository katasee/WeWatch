//
//  Webservice.swift
//  WeWatch
//
//  Created by Anton on 30/11/2024.
//

import Foundation

enum AuthenticationError: Error {
    case invalidCredentials
    case custom (errorMessage: String)
}

struct LoginRequestBody: Codable {
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

class Webservice {
    func login(apikey: String, pin: String, completion: @escaping (Result<String, AuthenticationError>) -> Void) {
        guard let url = URL(string: "https://api4.thetvdb.com/v4/login") else {
            completion(.failure(.custom(errorMessage: "URL is not correct")))
            return
        }
        
        let body = LoginRequestBody(apikey: apikey, pin: pin)
        
        var request = URLRequest(url:url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(body)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data, error == nil else {
                DispatchQueue.main.async {
                    completion(.failure(.custom(errorMessage: "No data or error: \(error?.localizedDescription ?? "Unknown")")))
                }
                return
            }
            
            guard let loginResponse = try? JSONDecoder().decode(LoginResponse.self, from: data) else {
                DispatchQueue.main.async {
                    completion(.failure(.invalidCredentials))
                }
                return
            }
            
            guard loginResponse.status == "success", let token = loginResponse.data?.token else {
                DispatchQueue.main.async {
                    let message = "Login failed: \(loginResponse.status)"
                    completion(.failure(.custom(errorMessage: message)))
                }
                return
            }
            
            DispatchQueue.main.async {
                completion(.success(token))
            }
        }.resume()
    }
}
