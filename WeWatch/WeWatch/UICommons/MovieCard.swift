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
    private let image: URL?
    @State private var didTap: Bool = false

    
    internal init(
        title: String,
        ranking: Double,
        genres: String,
        storyline: String,
        image: URL?
    ) {
        self.title = title
        self.ranking = ranking
        self.genres = genres
        self.storyline = storyline
        self.image = image
    }
    
    internal var body: some View {
        HStack(alignment: .top) {
            VStack {
                ZStack(alignment: .topTrailing) {
                    filmImage
                    Spacer()
                    Button  {
                        self.didTap = true && self.didTap == false
                    } label: {
                        if didTap == true {
                            Bookmark(isActive: true)
                        } else {
                            Bookmark(isActive: false)
                        }
                    }
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
        AsyncImage(url: image) {
            image in
            image
                .image?.resizable()
        }
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
            storyline: "The world's most lethal odd couple - bodyguard Michael Bryce and hitman Darius Kincaid - are back on anoth......", 
            image: URL(string: "https://m.media-amazon.com/images/M/MV5BZjFhZmU5NzUtZTg4Zi00ZjRjLWI0YmQtODk2MzI4YjNhYTdkXkEyXkFqcGc@._V1_FMjpg_UX1000_.jpg")
        )
    }
}
