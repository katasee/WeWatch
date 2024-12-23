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
            self
                .blur(radius: 5)
            VStack{
                LottieView(animation: .named("loader"))
                    .playbackMode(.playing(.toProgress(1, loopMode: .loop)))
                Text("Loading...")
                Spacer(minLength: 20)
            }
            .frame(maxWidth: 343, maxHeight: 142)
            .foregroundStyle(.white)
            .font(.poppinsRegular16px)
            .background(.ultraThinMaterial,in: RoundedRectangle(cornerRadius: 16.0))
        }
    }
}
