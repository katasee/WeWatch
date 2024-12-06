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
            }
        }
        
        Button("Login") {
            viewModel.call()
        }
        .disabled(viewModel.isLoading)
        
        Button("See current token for account") {
 
        }
        .disabled(viewModel.isLoading)
        
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
        .disabled(viewModel.isLoading)
    }
}

#Preview {
    ContentView()
}
