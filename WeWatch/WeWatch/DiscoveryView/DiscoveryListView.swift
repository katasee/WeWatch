//
//  DiscoveryListView.swift
//  WeWatch
//
//  Created by Anton on 16/02/2025.
//

import SwiftUI

internal struct DiscoveryListView: View {
    
    @MainActor private let dataForAllMovies: Array<Movie>
    private let refreshBookmark: @MainActor (Movie) async -> Void
    
    internal init(
        data: Array<Movie>,
        refreshBookmark: @escaping @MainActor (Movie) async -> Void
    ) {
        self.dataForAllMovies = data
        self.refreshBookmark = refreshBookmark
    }
    
    internal var body: some View {
        VStack(alignment: .leading) {
            allMovie
        }
    }
    
    
    private let columns: Array<GridItem> = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    private var allMovie: some View {
        LazyVGrid(columns: columns) {
            ForEach(dataForAllMovies) { model in
                Button {
                } label: {
                    NavigationLink(
                        destination: DetailsView(
                            viewModel: DetailsViewModel(movieId: model.id)
                        )
                    ) {
                        MovieCardDiscover(
                            refreshBookmark: refreshBookmark,
                            movie: model,
                            didTap: { isActive in
                                Task {
                                    await refreshBookmark(model)
                                }
                            }
                        )
                    }
                }
            }
        }
    }
}
