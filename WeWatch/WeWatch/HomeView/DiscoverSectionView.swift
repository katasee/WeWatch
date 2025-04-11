//
//  DiscoverSectionView.swift
//  WeWatch
//
//  Created by Anton on 19/01/2025.
//

import SwiftUI

internal struct DiscoverSectionView: View {
    
    private let dataForAllMovies: Array<Movie>
    private let seeMoreButtonAction: @MainActor () -> Void
    private let refreshBookmark: @MainActor (Movie) -> Void
    private let loadMore: @MainActor () -> Void
    private let isLoading: Bool
    
    internal init(
        dataForAllMovies: Array<Movie>,
        seeMoreButtonAction: @escaping @MainActor () -> Void,
        refreshBookmark: @escaping @MainActor (Movie) -> Void,
        loadMore: @escaping @MainActor () -> Void,
        isLoading: Bool
    ) {
        self.dataForAllMovies = dataForAllMovies
        self.seeMoreButtonAction = seeMoreButtonAction
        self.refreshBookmark = refreshBookmark
        self.loadMore = loadMore
        self.isLoading = isLoading
    }
    
    internal var body: some View {
        VStack(spacing: 5) {
            HStack {
                title
                Spacer()
                seeMoreButton
            }
            movieCardButton
        }
        if isLoading {
            self
                .loadingIndicator(isLoading: isLoading)
        }
    }
    
    private var title: some View {
        Text("home.title")
            .foregroundColor(.whiteColor)
            .font(.poppinsBold24px)
        + Text(". ")
            .foregroundColor(.fieryRed)
            .font(.poppinsBold24px)
    }
    
    private var seeMoreButton: some View {
        NavigationLink(
            destination: DiscoveryView(
                viewModel: DiscoveryViewModel()
            )
        ) {
            Text("home.see.more.button.title")
                .font(.poppinsRegular16px)
                .foregroundColor(.fieryRed)
        }
    }
    private let columns: Array<GridItem> = [
        GridItem(.flexible())
    ]
    
    private var movieCardButton: some View {
        LazyVGrid(columns: columns, alignment: .leading) {
            ForEach(dataForAllMovies.indices, id: \.self) { index in
                let movie = dataForAllMovies[index]
                NavigationLink(
                    destination: DetailsView(
                        viewModel: DetailsViewModel(movieId: movie.id)
                    )
                ) {
                    MovieCard(
                        refreshBookmark: refreshBookmark,
                        movie: movie
                    )
                    .multilineTextAlignment(.leading)
                }
                .onAppear {
                    if index == dataForAllMovies.count - 1 {
                        loadMore()
                    }
                }
            }
        }
    }
}
