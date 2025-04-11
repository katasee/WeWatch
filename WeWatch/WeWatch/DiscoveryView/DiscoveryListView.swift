//
//  DiscoveryListView.swift
//  WeWatch
//
//  Created by Anton on 16/02/2025.
//

import SwiftUI

internal struct DiscoveryListView: View {
    
    @MainActor private let dataForAllMovies: Array<Movie>
    private let refreshBookmark: @MainActor (Movie) -> Void
    private let loadMore: @MainActor () -> Void
    private let isLoading: Bool
    
    internal init(
        data: Array<Movie>,
        refreshBookmark: @escaping @MainActor (Movie) -> Void,
        loadMore: @escaping @MainActor () -> Void,
        isLoading: Bool
    ) {
        self.dataForAllMovies = data
        self.refreshBookmark = refreshBookmark
        self.loadMore = loadMore
        self.isLoading = isLoading
    }
    
    internal var body: some View {
        VStack(alignment: .leading) {
            allMovie
        }
        if isLoading {
            self
                .loadingIndicator(isLoading: isLoading)
        }
    }
    
    private let columns: Array<GridItem> = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    private var allMovie: some View {
        LazyVGrid(columns: columns) {
            ForEach(dataForAllMovies.indices, id: \.self) { index in
                let movie = dataForAllMovies[index]
                NavigationLink(
                    destination: DetailsView(
                        viewModel: DetailsViewModel(movieId: movie.id))
                ) {
                    Spacer()
                    MovieCardDiscover(
                        refreshBookmark: refreshBookmark,
                        movie: movie
                    )
                    Spacer()
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
