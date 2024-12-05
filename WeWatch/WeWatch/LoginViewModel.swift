//
//  LoginViewModel.swift
//  WeWatch
//
//  Created by Anton on 30/11/2024.
//

import Foundation

class LoginViewModel: ObservableObject {
    
    @Published var apikey: String = ""
    @Published var pin: String = ""
    @Published var isLoading: Bool = false
    @Published var token: String? = nil
    @Published var errorMessage: String? = nil
    
    func call() {
        isLoading = true
        
        let apikey: String = Environment.getPlistValue(.apiKey)
        let pin: String = Environment.getPlistValue(.apiPin)
        let loginBody = LoginRequestBody(apikey: apikey, pin: pin)
        
        guard let loginData = try? JSONEncoder().encode(loginBody) else {
            self.errorMessage = "failed to encode login data."
            self.isLoading = false
            return
        }
        
        let loginResource = Resource<LoginResponse>(
            url:URL.loginURL,
            method: .post(loginData)
        )
        Task {
            do {
                let response: LoginResponse = try await Webservice().call(loginResource)
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
