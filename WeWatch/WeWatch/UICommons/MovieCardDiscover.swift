//
//  MovieCardDiscover.swift
//  WeWatch
//
//  Created by Anton on 26/12/2024.
//

import SwiftUI
import Kingfisher


internal struct MovieCardDiscover: View {
    
    private let refreshBookmark: @MainActor(Movie) async -> Void
    @State private var isLoading: Bool = true
    private let movie: Movie
    private var didTap: @MainActor(Bool) -> Void

    
    internal init(
        
        refreshBookmark: @escaping @MainActor(Movie) async -> Void,
        movie: Movie,
        didTap: @escaping @MainActor(Bool) -> Void
    ) {
        self.refreshBookmark = refreshBookmark
        self.movie = movie
        self.didTap = didTap
    }
    
    internal var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            ZStack(alignment: .topTrailing) {
                filmImage
                Spacer()
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
            Text(movie.title)
                .font(.poppinsBold18px)
                .lineLimit(1)
            HStack {
                filmRanking
                Image("star-full-icon")
            }
        }
        .foregroundColor(.whiteColor)
        .frame(maxWidth: 182)
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
            .frame(maxWidth: 182, maxHeight: 273)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.darkGreyColor)
            )
    }
}
