//
//  ContentView.swift
//  WeWatch
//
//  Created by Anton on 22/11/2024.
//

import SwiftUI
struct ContentView: View {
    @StateObject private var loginViewModel = LoginViewModel()
    @State private var status = ""
    
    var body: some View {
        Form {
            VStack {
                if loginViewModel.isLoading {
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
            }
        }
        
        Button("Login") {
            loginViewModel.call()
        }
        .disabled(loginViewModel.isLoading)
        
        Button("See current token for account") {
            do {
                let data = try KeychainManager.getData(key: "token")
                status = String(
                    decoding: data,
                    as: UTF8.self)
            } catch {
                print(error)
            }
        }
        .disabled(loginViewModel.isLoading)
        
        Spacer()
        
        Button("Clear") {
            status = ""
            do {
                try KeychainManager.remove(key: "token")
                print("Password deleted successfully.")
            } catch {
                print("error")
            }
        }
        .disabled(loginViewModel.isLoading)
    }
}

#Preview {
    ContentView()
}
