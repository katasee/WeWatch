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
            VStack(alignment: .leading, spacing: 5) {
                filmTitle
                filmGenres
                    filmRelease
                storyLine
            }
        }
    }
    
    private var filmImage: some View {
        KFImage(URL(string: movie.posterUrl))
            .placeholder({
                ZStack {
                    Rectangle()
                        .loadingIndicator()
                }
            })
            .resizable()
            .frame(maxWidth: 152, maxHeight: 243)
            .aspectRatio(contentMode: .fill)
            .cornerRadius(15)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.darkGreyColor)
            )
    }
    
    private var filmTitle: some View {
        Text(movie.title)
            .font(.poppinsBold18px)
            .foregroundColor(.whiteColor)
    }
    
    private var filmRelease: some View {
        Text("movieCard.release.year \(movie.year)")
            .font(.poppinsRegular14px)
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
