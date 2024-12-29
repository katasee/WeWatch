//
//  MovieCardTopFive.swift
//  WeWatch
//
//  Created by Anton on 26/12/2024.
//

import SwiftUI

internal struct MovieCardTopFive: View {
    
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
        VStack(alignment: .leading) {
            HStack {
                Spacer()
                Bookmark()
                    .padding(16)
            }
            .padding(16)
            .frame(maxWidth: 300, maxHeight: 200, alignment: .topLeading)
            .background(RoundedRectangle(cornerRadius: 15)
                .fill(Color.darkGreyColor))
            filmTitle
            HStack {
                filmRanking
                RatingView(ranking: ranking)
            }
        }
    }
    private var filmRanking: some View {
        Text("\(ranking, specifier: "%.1f")")
            .font(.poppinsRegular22px)
            .foregroundColor(.whiteColor)
    }
    private var filmTitle: some View {
        Text(title)
            .font(.poppinsBold20px)
            .foregroundColor(.whiteColor)
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea();
        MovieCardTopFive(
            title: "Hitman’s Wife’s Bodyguard",
            ranking: 3.5
        )
    }
}
