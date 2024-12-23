//
//  SplashViewModel.swift
//  WeWatch
//
//  Created by Anton on 18/12/2024.
//

import Foundation

internal final class SplashViewModel: ObservableObject {
    
    internal enum JwtViewError: Error {
        case typeChangeError
        case invalidExpirationClaim
        case dataError
    }
    
    internal enum KeychainKey {
        static let token: String = "token"
    }
    
    internal enum JWTClaim {
        static let expiration = "exp"
    }
    
    private var token: String?
    private var errorMessage: String?
    @Published internal var showMainView: Bool = false
    @Published internal var isLoading: Bool = false
    
    @MainActor
    internal func loginToSplashView() async {
        if isValidToken() {
            isLoading = false
            self.showMainView = true
        } else {
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
                        self.showMainView = true
                    } catch {
                        self.errorMessage = "Failed to store token: \(error.localizedDescription)"
                    }
                } else {
                    self.errorMessage = "Failed to retriev token"
                }
            } catch {
                self.errorMessage = "Error during login: \(error.localizedDescription)"
            }
        }
    }
    
    internal func decodingJwtToken() throws -> [String: Any] {
        let tokenData: Data? = try KeychainManager.getData(key: KeychainKey.token)
        let token: String = .init(decoding: tokenData ?? Data(), as: UTF8.self)
        let jwtDecoder: JWTDecoder = .init()
        let decodeToken: [String: Any] = try jwtDecoder.decode(jwtoken: token)
        return decodeToken
    }
    
    internal func jwtExpiryDate() -> Date? {
        do {
            let decodeToken: [String: Any] = try decodingJwtToken()
            guard let expiredClaim: Any = decodeToken[JWTClaim.expiration],
                  let timeInterval: TimeInterval = expiredClaim as? TimeInterval else {
                throw JwtViewError.invalidExpirationClaim
            }
            return Date(timeIntervalSince1970: timeInterval)
        } catch {
            return nil
        }
    }
    
    internal func isValidToken() -> Bool {
        do {
            if let date: Date = jwtExpiryDate() {
                return date > .now
            } else {
                throw JwtViewError.dataError
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
            return nil
        }
    }
}
