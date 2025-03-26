//
//  MovieCardDiscover.swift
//  WeWatch
//
//  Created by Anton on 26/12/2024.
//

import SwiftUI
import Kingfisher


internal struct MovieCardDiscover: View {
    
    @State private var isActive: Bool
    @State private var isLoading: Bool = true
    private let movie: Movie
    private var didTap: @MainActor(Bool) -> Void
    private let bookmarkAddAction: @MainActor(Movie) async -> Void
    private let bookmarkRemoveAction: @MainActor(Movie) async -> Void
    
    internal init(
        isActive: Bool,
        movie: Movie,
        didTap: @escaping @MainActor(Bool) -> Void,
        bookmarkAddAction: @escaping @MainActor(Movie) async -> Void,
        bookmarkRemoveAction: @escaping @MainActor(Movie) async -> Void
    ) {
        self.isActive = isActive
        self.movie = movie
        self.didTap = didTap
        self.bookmarkAddAction = bookmarkAddAction
        self.bookmarkRemoveAction = bookmarkRemoveAction
    }
    
    internal var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            ZStack(alignment: .topTrailing) {
                filmImage
                Spacer()
                Button {
                    isActive.toggle()
                    didTap(isActive)
                    if isActive == true {
                        Task {
                            await bookmarkAddAction(movie)
                        }
                    } else {
                        Task {
                            await bookmarkRemoveAction(movie)
                        }
                    }
                } label: {
                    if isActive == true {
                        Bookmark(isActive: true)
                    } else {
                        Bookmark(isActive: false)
                    }
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
