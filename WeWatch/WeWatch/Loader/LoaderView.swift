//
//  LoaderView.swift
//  WeWatch
//
//  Created by Anton on 22/12/2024.
//

import SwiftUI
import Lottie

extension View {
    
    internal func loader(isLoading: Binding<Bool>) -> some View {
        ZStack {
            VStack{
                LottieView(animation: .named("loader"))
                    .playbackMode(.playing(.toProgress(1, loopMode: .loop)))
                Text("loader.label.title")
                Spacer(minLength: 20)
                
            }
            .frame(maxWidth: .infinity, maxHeight: 142)
            .foregroundColor(.whiteColor)
            .font(.poppinsRegular16px)
            .background(RoundedRectangle(cornerRadius: 12.0).fill(Color.darkGreyColor))
            .padding(.horizontal, 24)

        }
    }
}
