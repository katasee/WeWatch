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
    
    func login() {
        Webservice().login(apikey: apikey, pin: pin) { result in
            switch result {
            case .success(let token):
                print(token)
            case .failure(let error):
                print(error.localizedDescription )
            }
        }
    }
}
