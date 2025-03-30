//
//  LoaderView.swift
//  WeWatch
//
//  Created by Anton on 22/12/2024.
//

import SwiftUI
import Lottie

extension View {
    
    internal func loader(isLoading: Bool) -> some View {
        ZStack {
            if isLoading {
                VStack {
                    TimelineView(.animation) { timeline in
                        let angle = Double(timeline.date.timeIntervalSinceReferenceDate).truncatingRemainder(dividingBy: 1) * 360
                        Image(systemName: "gyroscope")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundColor(Color.fieryRed)
                            .rotationEffect(Angle(degrees: angle))
                        Text("loader.label.title")
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: 142)
                .foregroundColor(.whiteColor)
                .font(.poppinsRegular16px)
                .background(RoundedRectangle(cornerRadius: 12.0).fill(Color.darkGreyColor))
                .padding(.horizontal, 24)
            } else {
                self
            }
        }
    }
}
