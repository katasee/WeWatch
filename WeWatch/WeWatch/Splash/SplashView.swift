//
//  splashView.swift
//  WeWatch
//
//  Created by Anton on 18/12/2024.
//

import SwiftUI

internal struct SplashView: View {
    
    @StateObject private var viewModel: SplashViewModel = .init()
    
    private var splashViewContent: some View {
        ZStack {
            Color(.black)
                .ignoresSafeArea()
            VStack{
                HStack(spacing: 0) {
                    Text("splashView.title.first.part")
                        .foregroundColor(.whiteColor)
                    Text("splashView.title.second.part")
                        .foregroundColor(.fieryRed)
                }
                .font(.poppinsBold30px)
                Image.splashScreenIcon
                Group {
                    Text("splash.view.description.first.part.title")
                        .foregroundColor(.whiteColor)
                    + Text(". ")
                        .foregroundColor(.fieryRed)
                    + Text("splash.view.description.second.part.title")
                        .foregroundColor(.whiteColor)
                    + Text(". ")
                        .foregroundColor(.fieryRed)
                    + Text("splash.view.description.third.part.title")
                        .foregroundColor(.whiteColor)
                }
                .font(.poppinsBold24px)
            }
        }
    }
    
    internal var body: some View {
        if viewModel.showMainView {
            TabBar()
        } else {
            splashViewContent
                .task {
                    await viewModel.loginToSplashView()
                }
        }
    }
}

#Preview {
     SearchView()
}
