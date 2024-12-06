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
    
    internal func call() {
        isLoading = true
        
        let apikey: String = Environment.getPlistValue(.apiKey)
        let pin: String = Environment.getPlistValue(.apiPin)
        let loginBody: LoginRequestBody = .init(
            apikey: apikey,
            pin: pin
        )
        
        var loginResource: Resource<LoginResponse>?
        do {
            let loginData: Data = try JSONEncoder().encode(loginBody)
            let loginResource: Resource<LoginResponse> = Resource<LoginResponse>(
                url: URL.loginURL,
                method:  .post(loginData)
            )
        } catch {
            self.errorMessage = "failed to encode login data."
            self.isLoading = false
            return
        }
        
        Task {
            guard let resource = loginResource else {
                self.errorMessage = "The resource is not initialized."
                isLoading = false
                return
            }
            do {
                let response: LoginResponse = try await Webservice().call(resource)
                if let token = response.data?.token {
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
}
