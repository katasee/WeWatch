//
//  LoginViewModel.swift
//  WeWatch
//
//  Created by Anton on 30/11/2024.
//

import Foundation

internal final class LoginViewModel: ObservableObject {
    
    @Published internal var apikey: String = ""
    @Published internal var pin: String = ""
    @Published internal var isLoading: Bool = false
    @Published internal var token: String? = nil
    @Published internal var errorMessage: String? = nil
    
    @MainActor
    internal func call() {
        isLoading = true
        guard let loginData: Data = prepareLoginRequest() else {
            self.errorMessage = "failed to encode login data."
            return
        }
        let loginResource: Resource<LoginResponse> = Resource<LoginResponse>(
            url: URL.loginURL,
            method: .post(loginData)
        )
        
        Task {
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
    }
    
    internal func decodingJwtToken() -> [String: Any]? {
        guard let tokenData: Data = try? KeychainManager.getData(key: "token") else {
            return nil
        }
        let token: String = String(decoding: tokenData, as: UTF8.self)
        let jwtDecoder: JWTDecoder = JWTDecoder()
        let decodeToken: [String: Any] = jwtDecoder.decode(jwtoken: token)
        return decodeToken
    }
    
    internal func expiredTime() -> Int {
        let decodeToken: [String: Any]? = decodingJwtToken()
        let claim: String = "exp"
        guard let experienceClaim: Int = decodeToken?[claim] as? Int else {
            return 0
        }
        return experienceClaim
    }
    
    internal func validToken() {
        let claim: String = "exp"
        let decodeToken: [String : Any]? = decodingJwtToken()
        guard let experienceClaim: Any = decodeToken?[claim] else {
            return
        }
        guard let intExperienceClaim = experienceClaim as? Int else {
            return
        }
        if intExperienceClaim > 0 {
            print("token valid")
        } else {
            print ("you need refresh token")
        }
    }
    private func prepareLoginRequest () -> Data? {
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
