//
//  SearchListView.swift
//  WeWatch
//
//  Created by Anton on 23/01/2025.
//

import SwiftUI

internal struct SearchListView: View {
    
    private let didTap: Bool
    private let data: Array<Movie>
    private let seeMoreButtonAction: @MainActor () -> Void
    private let chooseButtonAction: @MainActor (Movie) -> Void
    private let bookmarkAddAction: @MainActor (Movie) async -> Void
    private let bookmarkRemoveAction: @MainActor (Movie) async -> Void

    
    internal init(
        didTap: Bool,
        data: Array<Movie>,
        seeMoreButtonAction: @escaping @MainActor () -> Void,
        chooseButtonAction: @escaping @MainActor (Movie) -> Void,
        bookmarkAddAction: @escaping @MainActor (Movie) async -> Void,
        bookmarkRemoveAction: @escaping @MainActor (Movie) async -> Void


    ) {
        self.didTap = didTap
        self.data = data
        self.seeMoreButtonAction = seeMoreButtonAction
        self.chooseButtonAction = chooseButtonAction
        self.bookmarkAddAction = bookmarkAddAction
        self.bookmarkRemoveAction = bookmarkRemoveAction
    }
    
    internal var body: some View {
        VStack(alignment: .leading) {
            movieCardButton
        }
    }
    
    private var movieCardButton: some View {
        ForEach(data) { model in
            Button {
                chooseButtonAction(model)
            } label: {
                NavigationLink(destination: DetailsView(
                    viewModel: DetailsViewModel(
                        dbManager: DatabaseManager(
                            dataBaseName: DatabaseConfig.name
                        ), movieId: model.id
                    )
                )
                ) {
                    MovieCard(
                        refreshBookmark: {_ in}, movie: model,
                        didTap: { isActive in },
                        bookmarkAddAction: bookmarkAddAction,
                        bookmarkRemoveAction: bookmarkRemoveAction
                    )
                    .multilineTextAlignment(.leading)
                }
            }
        }
    }
}
