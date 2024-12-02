//
//  LoginViewModel.swift
//  WeWatch
//
//  Created by Anton on 30/11/2024.
//

import Foundation

class LoginViewModel: ObservableObject {
    var apikey: String = ""
    var pin: String = ""
    @Published var isLoading: Bool = false
    
    func login() {
        isLoading = true
        Webservice().login(apikey: Environment.apiKey, pin: Environment.apiPin) { [weak self] result in
            self?.isLoading = false
            switch result {
            case .success(let token):
                print(token)
                do {
                    try KeychainManager.store(data: token, key: "token")
                } catch {
                    print(error)
                }
            case .failure(let error):
                print(error.localizedDescription )
            }
        }
    }
}
