//
//  SplashViewModel.swift
//  WeWatch
//
//  Created by Anton on 18/12/2024.
//

import SwiftUI

struct SplashView: View {
    
    @StateObject var viewModel = SplashViewModel()
    
    var body: some View {
        if viewModel.showMainView {
            ContentView()
        } else {
            ZStack{
                Color(.black)
                    .ignoresSafeArea()
                VStack{
                    HStack(spacing: 0) {
                        Text("We")
                            .foregroundColor(.whiteColor)
                        Text("Watch.")
                            .foregroundColor(.fieryRed)
                    }
                    .font(.poppinsBold30px)
                    Image("SplashScreen icon")
                    Group {
                        Text("Discover")
                            .foregroundColor(.whiteColor)
                        + Text(". ")
                            .foregroundColor(.fieryRed)
                        + Text("Track")
                            .foregroundColor(.whiteColor)
                        + Text(". ")
                            .foregroundColor(.fieryRed)
                        + Text("Enjoy")
                            .foregroundColor(.whiteColor)
                    }
                    .font(.poppinsBold24px)
                }
            }
            .onAppear {
                Task {
                    await viewModel.loginToSplashView()
                }
            }
        }
    }
}

#Preview {
    SplashView()
}
