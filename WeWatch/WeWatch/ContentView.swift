//
//  ContentView.swift
//  WeWatch
//
//  Created by Anton on 22/11/2024.
//

import SwiftUI
struct ContentView: View {
    
    @StateObject private var loginVM = LoginViewModel()
    
    var body: some View {
        VStack{
            Form {
                HStack{
                    Spacer()
                    Image(systemName: "lock.fill")
                }
                TextField("apikey", text: $loginVM.apikey)
                SecureField("pin", text: $loginVM.pin)
                HStack {
                    Spacer ()
                    Button("Login") {
                        loginVM.login()
                    }
                    Button("Signout") {
                         
                    }
                }
            }
        }
    }
}


#Preview {
    ContentView()
}
