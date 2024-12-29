//
//  MovieCardDiscover.swift
//  WeWatch
//
//  Created by Anton on 26/12/2024.
//

import SwiftUI

internal struct MovieCardDiscover: View {
    
    private let title: String
    private let ranking: Double
    
    internal init(
        title: String,
        ranking: Double
    ) {
        self.title = title
        self.ranking = ranking
    }
    
    internal var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            ZStack(alignment: .topTrailing) {
                filmImage
                Spacer()
                Bookmark()
                    .padding(16)
            }
            Text(title)
                .font(.poppinsBold18px)
            HStack {
                filmRanking
                Image("star-full-icon")
            }
        }
        .foregroundColor(.whiteColor)
        .frame(maxWidth: 182)
    }
    private var filmRanking: some View {
        Text("\(ranking, specifier: "%.1f")")
            .font(.poppinsRegular18px)
    }
    private var filmImage: some View {
        ImageComponent(image: Image("splash.screen.icon"))
            .cornerRadius(15)
            .frame(maxWidth: 182, maxHeight: 273)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.darkGreyColor)
            )
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        MovieCardDiscover(
            title: "Hitman’s Wife’s Bodyguard",
            ranking: 3.5
        )
    }
}
