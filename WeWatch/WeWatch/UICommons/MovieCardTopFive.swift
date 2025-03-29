//
//  MovieCardTopFive.swift
//  WeWatch
//
//  Created by Anton on 26/12/2024.
//

import SwiftUI
import Kingfisher

internal struct MovieCardTopFive: View {
    
    private let refreshBookmark: @MainActor(Movie) async -> Void
    private let movie: Movie
    private var didTap: @MainActor (Bool) -> Void
    
    internal init(
        refreshBookmark: @escaping @MainActor(Movie) async -> Void,
        movie: Movie,
        didTap: @escaping @MainActor (Bool) -> Void
    ) {
        self.refreshBookmark = refreshBookmark
        self.movie = movie
        self.didTap = didTap
    }
    
    internal var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    ZStack(alignment: .topTrailing) {
                        KFImage(URL(string: movie.posterUrl))
                            .resizable()
                            .placeholder({
                                ZStack {
                                    Rectangle()
                                        .loadingIndicator()
                                }
                            })
                            .aspectRatio(contentMode: .fill)
                            .frame(maxWidth: 300, maxHeight: 200)
                            .clipped()
                        Button {
                            let movieSelected = !movie.isBookmarked
                            didTap(movieSelected)
                            Task {
                                await refreshBookmark(movie)
                            }
                        } label: {
                            Bookmark(isActive: movie.isBookmarked)
                        }
                        .padding(16)
                    }
                    .cornerRadius(15)
                    .background(RoundedRectangle(cornerRadius: 15)
                        .fill(Color.darkGreyColor))
                }
                filmTitle
            }
            HStack {
                filmRanking
                RatingView(ranking: movie.rating)
            }
        }
        .frame(width: 300)
        .fixedSize(horizontal: true, vertical: false)
        .lineLimit(1)
    }
    
    private var filmRanking: some View {
        Text("\(movie.rating, specifier: "%.1f")")
            .font(.poppinsRegular22px)
            .foregroundColor(.whiteColor)
    }
    
    private var filmTitle: some View {
        Text(movie.title)
            .font(.poppinsBold20px)
            .foregroundColor(.whiteColor)
    }
}
