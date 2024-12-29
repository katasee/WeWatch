//
//  MovieCard.swift
//  WeWatch
//
//  Created by Anton on 26/12/2024.
//

import SwiftUI

internal struct MovieCard: View {
    
    private let title: String
    private let ranking: Double
    private let genres: String
    private let storyline: String
    
    internal init(
        title: String,
        ranking: Double,
        genres: String,
        storyline: String
    ) {
        self.title = title
        self.ranking = ranking
        self.genres = genres
        self.storyline = storyline
    }
    
    internal var body: some View {
        HStack(alignment: .top) {
            VStack {
                ZStack(alignment: .topTrailing) {
                    filmImage
                    Spacer()
                    Bookmark()
                        .padding(16)
                }
            }
            VStack(alignment: .leading, spacing: 10) {
                filmTitle
                HStack {
                    filmRanking
                    RatingView(ranking: ranking)
                }
                filmGenres
                storyLine
            }
        }
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
    private var filmTitle: some View {
        Text(title)
            .font(.poppinsBold20px)
            .foregroundColor(.whiteColor)
    }
    private var filmRanking: some View {
        Text("\(ranking, specifier: "%.1f")")
            .font(.poppinsBold16px)
            .foregroundColor(.whiteColor)
    }
    private var filmGenres: some View {
        Text(genres)
            .font(.poppinsBold14px)
            .foregroundColor(.whiteColor)
    }
    private var storyLine: some View {
        Text(storyline)
            .font(.poppinsRegular13px)
            .foregroundColor(.lightGreyColor)
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        MovieCard(
            title: "Hitman’s Wife’s Bodyguard",
            ranking: 3.5,
            genres: "Action, Comedy, Crime",
            storyline: "The world's most lethal odd couple - bodyguard Michael Bryce and hitman Darius Kincaid - are back on anoth......"
        )
    }
}
