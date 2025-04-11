//
//  DetailsView.swift
//  WeWatch
//
//  Created by Anton on 28/01/2025.
//

import SwiftUI

internal struct DetailsView: View {
    
    @StateObject private var viewModel: DetailsViewModel
    
    internal init(viewModel: DetailsViewModel) {
        self._viewModel = .init(wrappedValue: viewModel)
    }
    
    internal var body: some View {
        ZStack {
            Color.black
            if let movie = viewModel.movieForDetailsView {
                NavigationBarButtons(
                    refreshBookmark: { movie in
                        viewModel.refreshBookmarked(
                            active: !movie.isBookmarked,
                            movieId: movie.id,
                            selectedMovie: movie
                        )
                    },
                    movie: movie
                )
                    VStack {
                        DetailSectionView(movie: movie)
                    .fullScreenErrorPopUp(error: $viewModel.error, onRetry: {
                        Task {
                            await viewModel.fetchData()
                        }
                    })
                    .fullScreenLoader(isLoading: viewModel.isLoading)
                }
            }
        }
        .task {
            await viewModel.fetchData()
        }
        .navigationBarBackButtonHidden(true)
        .ignoresSafeArea()
    }
}
