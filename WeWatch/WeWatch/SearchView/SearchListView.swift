//
//  SearchListView.swift
//  WeWatch
//
//  Created by Anton on 23/01/2025.
//

import SwiftUI

internal struct SearchListView: View {
    
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
        VStack(alignment: .leading) {
            movieCardButton
        }
        if isLoading {
            self
                .loadingIndicator(isLoading: isLoading)
        }
    }
    
    private let columns: Array<GridItem> = [
        GridItem(.flexible())
    ]
    
    private var movieCardButton: some View {
        LazyVGrid(columns: columns) {
            ForEach(dataForAllMovies.indices, id: \.self) { index in
                let movie = dataForAllMovies[index]
                NavigationLink(destination: DetailsView(
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
