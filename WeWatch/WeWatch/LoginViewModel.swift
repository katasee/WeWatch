//
//  LoginViewModel.swift
//  WeWatch
//
//  Created by Anton on 30/11/2024.
//

import Foundation

internal final class LoginViewModel: ObservableObject {
    
    internal enum viewJwtError: Error {
        
        case typeChangeError
        case invalidExpirationClaim
        case dataError
    }
    
    @Published internal var apikey: String = ""
    @Published internal var pin: String = ""
    @Published internal var isLoading: Bool = false
    @Published internal var token: String? = nil
    @Published internal var errorMessage: String? = nil
    
    @MainActor
    internal func call() async {
        isLoading = true
        guard let loginData: Data = prepareLoginRequest() else {
            self.errorMessage = "failed to encode login data."
            return
        }
        let loginResource: Resource<LoginResponse> = .init(
            url: URL.loginURL,
            method: .post(loginData)
        )
        
            do {
                let response: LoginResponse = try await Webservice().call(loginResource)
                if let token: String = response.data?.token {
                    self.token = token
                    do {
                        try KeychainManager.store(data: token, key: "token")
                    } catch {
                        self.errorMessage = "Failed to store token: \(error.localizedDescription)"
                    }
                } else {
                    self.errorMessage = "Failed to retriev token"
                }
            } catch {
                self.errorMessage = "Error during login: \(error.localizedDescription)"
            }
            isLoading = false
    }
    
    internal func decodingJwtToken() throws -> [String: Any] {
        guard let tokenData: Data = try? KeychainManager.getData(key: "token") else {
            throw viewJwtError.typeChangeError
        }
        let token: String = .init(decoding: tokenData, as: UTF8.self)
        let jwtDecoder: JWTDecoder = .init()
        let decodeToken: [String: Any] = try jwtDecoder.decode(jwtoken: token)
        return decodeToken
    }
    
    internal func getJWTTokenExpirationTime() -> Date? {
        do {
            let decodeToken: [String: Any] = try decodingJwtToken()
            let claim: String = "exp"
            guard let expiredClaim: Any = decodeToken[claim],
                  let timeInterval: TimeInterval = expiredClaim as? TimeInterval else {
                throw viewJwtError.invalidExpirationClaim
            }
            return Date(timeIntervalSince1970: timeInterval)
        } catch {
            return nil
        }
    }
    @MainActor
    internal func isValidToken() async -> Bool {
        do {
            if let date: Date = getJWTTokenExpirationTime() {
                return date > .now
            } else {
                throw viewJwtError.dataError
            }
        } catch {
            return false
        }
    }
    
    private func prepareLoginRequest() -> Data? {
        do {
            let apikey: String = Environment.getPlistValue(.apiKey)
            let pin: String = Environment.getPlistValue(.apiPin)
            let loginBody: LoginRequestBody = .init(
                apikey: apikey,
                pin: pin
            )
            let loginData: Data = try JSONEncoder().encode(loginBody)
            return loginData
        } catch {
            self.errorMessage = "failed to encode login data."
            self.isLoading = false
            return nil
        }
    }
}
