//
//  MovieCard.swift
//  WeWatch
//
//  Created by Anton on 26/12/2024.
//

import SwiftUI
import Kingfisher

internal struct MovieCard: View {
    
    private let refreshBookmark: @MainActor(Movie) -> Void
    private let movie: Movie
    
    internal init(
        refreshBookmark: @escaping @MainActor(Movie) -> Void,
        movie: Movie
    ) {
        self.refreshBookmark = refreshBookmark
        self.movie = movie
    }
    
    internal var body: some View {
        HStack(alignment: .top) {
            VStack {
                ZStack(alignment: .topTrailing) {
                    filmImage
                    Spacer()
                    Button {
                        refreshBookmark(movie)
                    } label: {
                        Bookmark(isActive: movie.isBookmarked)
                    }
                    .padding(16)
                }
            }
            VStack(alignment: .leading, spacing: 10) {
                filmTitle
                HStack {
                    filmRanking
                    RatingView(ranking: movie.rating)
                }
                filmGenres
                storyLine
            }
        }
    }
    
    private var filmImage: some View {
        KFImage(URL(string: movie.posterUrl))
            .resizable()
            .placeholder({
                ZStack {
                    Rectangle()
                        .loadingIndicator()
                }
            })
            .cornerRadius(15)
            .frame(maxWidth: 182, maxHeight: 273)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.darkGreyColor)
            )
    }
    
    private var filmTitle: some View {
        Text(movie.title)
            .font(.poppinsBold20px)
            .foregroundColor(.whiteColor)
    }
    
    private var filmRanking: some View {
        Text("\(movie.rating, specifier: "%.1f")")
            .font(.poppinsBold16px)
            .foregroundColor(.whiteColor)
    }
    
    private var filmGenres: some View {
        Text(movie.genres)
            .font(.poppinsBold14px)
            .foregroundColor(.whiteColor)
    }
    
    private var storyLine: some View {
        Text(movie.overview)
            .font(.poppinsRegular13px)
            .foregroundColor(.lightGreyColor)
            .lineLimit(4)
    }
}
