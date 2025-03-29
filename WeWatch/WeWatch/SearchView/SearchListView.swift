//
//  SearchListView.swift
//  WeWatch
//
//  Created by Anton on 23/01/2025.
//

import SwiftUI

internal struct SearchListView: View {
    
    private let data: Array<Movie>
    private let seeMoreButtonAction: @MainActor () -> Void
    private let refreshBookmark: @MainActor (Movie) async -> Void

    internal init(
 
        data: Array<Movie>,
        seeMoreButtonAction: @escaping @MainActor () -> Void,
        refreshBookmark: @escaping @MainActor (Movie) async -> Void
    ) {
        self.data = data
        self.seeMoreButtonAction = seeMoreButtonAction
        self.refreshBookmark = refreshBookmark
    }
    
    internal var body: some View {
        VStack(alignment: .leading) {
            movieCardButton
        }
    }
    
    private var movieCardButton: some View {
        ForEach(data) { model in
            Button {
            } label: {
                NavigationLink(destination: DetailsView(
                    viewModel: DetailsViewModel(movieId: model.id)
                )
                ) {
                    MovieCard(
                        refreshBookmark: refreshBookmark,
                        movie: model,
                        didTap: { isActive in
                            Task {
                                await refreshBookmark(model)
                            }
                        }
                    )
                    .multilineTextAlignment(.leading)
                }
            }
        }
    }
}
