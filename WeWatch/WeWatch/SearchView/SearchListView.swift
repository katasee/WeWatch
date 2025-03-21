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
    private var isActive: Bool
    private let seeMoreButtonAction: @MainActor () -> Void
    private let chooseButtonAction: @MainActor (Movie) -> Void
    
    internal init(
        didTap: Bool,
        data: Array<Movie>,
        isActive: Bool,
        seeMoreButtonAction: @escaping @MainActor () -> Void,
        chooseButtonAction: @escaping @MainActor (Movie) -> Void
    ) {
        self.didTap = didTap
        self.data = data
        self.isActive = isActive
        self.seeMoreButtonAction = seeMoreButtonAction
        self.chooseButtonAction = chooseButtonAction
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
                        isActive: false, title: model.title,
                        ranking: model.rating,
                        genres: model.genres,
                        storyline: model.overview,
                        imageUrl: URL(string: model.posterUrl),
                        didTap: { isActive in }
                    )
                    .multilineTextAlignment(.leading)
                }
            }
        }
    }
}
