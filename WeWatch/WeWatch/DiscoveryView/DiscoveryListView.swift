//
//  DiscoveryListView.swift
//  WeWatch
//
//  Created by Anton on 16/02/2025.
//

import SwiftUI

internal struct DiscoveryListView: View {
    
    @MainActor private let dataForAllMovies: Array<Movie>
    private let chooseButtonAction: @MainActor(Movie) -> Void
    private let bookmarkAddAction: @MainActor(Movie) async -> Void
    private let bookmarkRemoveAction: @MainActor(Movie) async -> Void

    internal init(
        data: Array<Movie>,
        chooseButtonAction: @escaping @MainActor(Movie) -> Void,
        bookmarkAddAction: @escaping @MainActor(Movie) async -> Void,
        bookmarkRemoveAction: @escaping @MainActor(Movie) async -> Void
    ) {
        self.dataForAllMovies = data
        self.chooseButtonAction = chooseButtonAction
        self.bookmarkAddAction = bookmarkAddAction
        self.bookmarkRemoveAction = bookmarkRemoveAction
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
                    chooseButtonAction(model)
                } label: {
                    NavigationLink(
                        destination: DetailsView(
                            viewModel: DetailsViewModel(
                                dbManager: DatabaseManager(
                                    dataBaseName: DatabaseConfig.name
                                ), movieId: model.id
                            )
                        )
                    ) {
                        MovieCardDiscover(
                            isActive: false,
                            movie: model,
                            didTap: { isActive in },
                            bookmarkAddAction: bookmarkAddAction,
                            bookmarkRemoveAction: bookmarkRemoveAction
                        )}
                }
            }
        }
    }
}
