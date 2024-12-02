//
//  ContentView.swift
//  WeWatch
//
//  Created by Anton on 22/11/2024.
//

import SwiftUI
struct ContentView: View {
    
    @StateObject private var loginVM = LoginViewModel()
    @State private var status = ""
    
    var body: some View {
        VStack{
            if loginVM.isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .red))
                    .disabled(true)
            }
            Form {
                HStack{
                    Spacer()
                    Image(systemName: "lock.fill")
                    Spacer()
                }
                Text(status)
                    .font(.callout)
                    .foregroundStyle(.green)
                    .onAppear(perform: loginVM.login)
            }
        }
        Button("See current token for account") {
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
        .disabled(loginVM.isLoading)
        Spacer()
        Button("Clear") {
            do {
                try KeychainManager.remove(key: "token")
                print("Password deleted successfully.")
            } catch {
                print("error")
            }
        }
        .disabled(loginVM.isLoading)
    }
}

#Preview {
    ContentView()
}
