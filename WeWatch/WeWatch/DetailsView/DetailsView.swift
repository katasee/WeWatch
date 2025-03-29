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
            if let movie = viewModel.movieForDetailsView {
                NavigationBarButtons(
                    refreshBookmark: { movie in
                        viewModel.refreshBookmarked(
                            active: !movie.isBookmarked,
                            movieId: movie.id
                        )
                    },
                    movie: movie
                )
                ScrollView {
                    VStack {
                        DetailSectionView(movie: movie)
                    }
                }
            }
            
        }
        .task {
            await viewModel.dataFromEndpoint()
        }
        .ignoresSafeArea()
    }
}
