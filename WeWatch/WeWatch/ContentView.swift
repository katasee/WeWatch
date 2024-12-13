//
//  ContentView.swift
//  WeWatch
//
//  Created by Anton on 22/11/2024.
//

import SwiftUI

internal struct ContentView: View {
    @StateObject private var viewModel: LoginViewModel = .init()
    @State private var status: String = ""
    @State private var expireTime: Date = Date()
    @State private var validToken: Bool = false
    
    var body: some View {
        Form {
            VStack {
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .red))
                        .disabled(true)
                }
                HStack {
                    Spacer()
                    Image(systemName: "lock.fill")
                    Spacer()
                }
                Text(status)
                    .font(.poppinsRegular16px)
                    .foregroundStyle(.green)
                
                Text(viewModel.errorMessage ?? "")
                if validToken {
                    Text("Result: \(expireTime)")
                        .foregroundColor(.green)
                } else {
                    Text("Token is expired: \(expireTime)")
                        .foregroundColor(.red)
                }
            }
        }
        
        Button("Login") {
            viewModel.call()
        }
        .disabled(viewModel.isLoading)
        
        Button("See current token") {
            do {
                let data = try KeychainManager.getData(key: "token")
                status = String(
                    decoding: data,
                    as: UTF8.self
                )
            } catch {
                print(error)
            }
        }
        .disabled(viewModel.isLoading)
        
        Button("Update token") {
            do {
                _ = try KeychainManager.update(key: "token", newData: "newTokenValue")
                print("token update successfully")
            } catch {
                print("error")
            }
        }
        
        Button("Experience Time") {
            expireTime = LoginViewModel().getJWTTokenExpirationTime() ?? Date()
        }
        
        Button("Check Token Status") {
            validToken = viewModel.isValidToken()
        }
        
        Button("Clear") {
            viewModel.errorMessage = nil
            status = ""
            do {
                try KeychainManager.remove(key: "token")
                print("Password deleted successfully.")
            } catch {
                print("error")
            }
        }
        .disabled(viewModel.isLoading)
    }
}

#Preview {
    ContentView()
}
