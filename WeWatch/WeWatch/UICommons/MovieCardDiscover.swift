//
//  MovieCardDiscover.swift
//  WeWatch
//
//  Created by Anton on 26/12/2024.
//

import SwiftUI
import Kingfisher


internal struct MovieCardDiscover: View {
    
    private let refreshBookmark: @MainActor(Movie) -> Void
    @State private var isLoading: Bool = true
    private let movie: Movie
    
    internal init(
        refreshBookmark: @escaping @MainActor(Movie) -> Void,
        movie: Movie
    ) {
        self.refreshBookmark = refreshBookmark
        self.movie = movie
    }
    
    internal var body: some View {
        VStack(alignment: .leading, spacing: 5) {
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
            Text(movie.title)
                .font(.poppinsBold18px)
                .lineLimit(1)
            HStack {
                filmRanking
                Image("star-full-icon")
            }
        }
        .foregroundColor(.whiteColor)
        .frame(maxWidth: .infinity)
    }
    
    private var filmRanking: some View {
        Text("\(movie.rating, specifier: "%.1f")")
            .font(.poppinsRegular18px)
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
            .frame(maxHeight: 275)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.darkGreyColor)
            )
    }
}
