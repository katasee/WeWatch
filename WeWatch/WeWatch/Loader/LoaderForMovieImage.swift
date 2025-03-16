//
//  LoaderForMovieImage.swift
//  WeWatch
//
//  Created by Anton on 16/03/2025.
//

import SwiftUI

extension View {
    @ViewBuilder
    func loadingIndicator() -> some View {
        TimelineView(.animation) { timeline in
            let angle = Double(timeline.date.timeIntervalSinceReferenceDate).truncatingRemainder(dividingBy: 1) * 360
            Image(systemName: "gyroscope")
                .resizable()
                .frame(width: 24, height: 24)
                .foregroundColor(Color.fieryRed)
                .rotationEffect(Angle(degrees: angle))
        }
    }
}
