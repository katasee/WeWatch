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
    @State private var expireTime: Int = 0
    @State private var validToken: Int = 0
    
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
                let date = Date(timeIntervalSince1970: TimeInterval(expireTime))
                if date > Date() {
                    
                    Text("Result: \(date)")
                        .foregroundColor(.green)
                } else {
                    Text("Valid time: \(date)")
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
            expireTime = viewModel.expiredTime()
        }
        
        Button("Check Token Status") {
            LoginViewModel().validToken()
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
