//
//  splashView.swift
//  WeWatch
//
//  Created by Anton on 18/12/2024.
//

import SwiftUI

struct SplashView: View {
    
    @StateObject private var viewModel: SplashViewModel = .init()
    
    private var splashViewContent: some View {
        ZStack {
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
                Image.splashScreenIcon
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
            .loader(isLoading: $viewModel.isLoading)
        }
    }
    
    internal var body: some View {
        if viewModel.showMainView {
            ContentView()
        } else {
            splashViewContent
                .task {
                    await viewModel.loginToSplashView()
                }
        }
    }
}

#Preview {
    SplashView()
}
