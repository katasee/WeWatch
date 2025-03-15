//
//  MovieCard.swift
//  WeWatch
//
//  Created by Anton on 26/12/2024.
//

import SwiftUI

internal struct MovieCard: View {
    
    @State private var isActive: Bool
    private let title: String
    private let ranking: Double
    private let genres: String
    private let storyline: String
    private let image: URL?
    private var didTap: @MainActor (Bool) -> Void
    
    internal init(
        isActive: Bool,
        title: String,
        ranking: Double,
        genres: String,
        storyline: String,
        imageUrl: URL?,
        didTap: @escaping @MainActor (Bool) -> Void
    ) {
        self.isActive = isActive
        self.title = title
        self.ranking = ranking
        self.genres = genres
        self.storyline = storyline
        self.image = imageUrl
        self.didTap = didTap
    }
    
    internal var body: some View {
        HStack(alignment: .top) {
            VStack {
                ZStack(alignment: .topTrailing) {
                    filmImage
                    Spacer()
                    Button {
                        isActive.toggle()
                        didTap(isActive)
                    } label: {
                        if isActive == true {
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
            .lineLimit(4)
    }
}
