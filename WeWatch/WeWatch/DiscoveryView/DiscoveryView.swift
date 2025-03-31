//
//  DiscoveryView.swift
//  WeWatch
//
//  Created by Anton on 16/02/2025.
//

import SwiftUI

internal struct DiscoveryView: View {
    
    @StateObject private var viewModel: DiscoveryViewModel
    
    internal init(viewModel: DiscoveryViewModel) {
        self._viewModel = .init(wrappedValue: viewModel)
    }
    
    internal var body: some View {
        ZStack {
            BackButton()
            Color.black
                .ignoresSafeArea()
            VStack {
                MovieCategoryView(
                    genreTabs: viewModel.genresForDiscoveryView,
                    selectedGenre: viewModel.selectedGenre,
                    action: { genre in
                        viewModel.selectedGenre = genre
                    }
                )
                ScrollView {
                    Color.clear.frame(height: 16) 
                    LazyVStack {
                        DiscoveryListView(
                            data: viewModel.dataForAllMovieTab,
                            refreshBookmark: { movie in
                                viewModel.refreshBookmarked(
                                    active: !movie.isBookmarked,
                                    movieId: movie.id, selectedMovie: movie
                                )
                            }
                        )
                        Rectangle()
                            .loadingIndicator(isLoading: viewModel.isFetchingNextPage)
                            .frame(minHeight: 16)
                            .foregroundColor(Color.clear)
                            .onAppear {
                                viewModel.fetchNextPage()
                            }
                    }
                    .onChange(of: viewModel.selectedGenre) { change in
                        Task {
                            await viewModel.fetchData()
                        }
                    }
                }
                .fullScreenLoader(isLoading: viewModel.isLoading)
            }
            .task {
                await viewModel.dataFromEndpointForGenreTabs()
                await viewModel.fetchData()
            }
        }
    }
    
}
