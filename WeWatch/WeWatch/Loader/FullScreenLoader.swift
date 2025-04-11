//
//  FullScreenLoader.swift
//  WeWatch
//
//  Created by Anton on 31/03/2025.
//

import SwiftUI

struct FullScreenLoader: ViewModifier {
    
   internal let isLoading: Bool
    
    internal func body(content: Content) -> some View {
        content
            .blur(radius: isLoading ? 10 : 0)
            .allowsHitTesting(isLoading ? false : true)
            .overlay(alignment: .center) {
                if isLoading {
                    loader
                }
            }
    }
    
    private var loader: some View {
        VStack() {
            TimelineView(.animation) { timeline in
                let angle = Double(timeline.date.timeIntervalSinceReferenceDate).truncatingRemainder(dividingBy: 1) * 360
                Image(systemName: "gyroscope")
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundColor(Color.fieryRed)
                    .rotationEffect(Angle(degrees: angle))
            }
            Text("loader.label.title") 
        }
        .frame(maxWidth: 300 , maxHeight: 142)
        .foregroundColor(.whiteColor)
        .font(.poppinsRegular16px)
        .background(RoundedRectangle(cornerRadius: 12.0).fill(Color.darkGreyColor))
        .padding(.horizontal, 24)
    }
}

extension View {
    func fullScreenLoader(isLoading: Bool) -> some View {
        modifier(FullScreenLoader(isLoading: isLoading))
    }
}
