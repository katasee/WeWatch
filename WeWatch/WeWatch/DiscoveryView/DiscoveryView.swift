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
                movieCategoryList
                ScrollView {
                    Color.clear.frame(height: 16)
                    LazyVStack {
                        discoveryList
                        rectangle
                    }
                }
                .onChange(of: viewModel.selectedGenre) { change in
                    Task {
                        await viewModel.fetchData()
                    }
                }
                .fullScreenErrorPopUp(error: $viewModel.error, onRetry: {
                    Task {
                        if viewModel.fetchDataError {
                            await viewModel.fetchData()
                            viewModel.fetchDataError = false
                        } else if viewModel.appendDataError {
                            await viewModel.fetchNextPage()
                            viewModel.appendDataError = false
                        }
                    }
                })
                .fullScreenLoader(isLoading: viewModel.isLoading)
            }
            .task {
                await viewModel.dataFromEndpointForGenreTabs()
                await viewModel.fetchData()
            }
        }
    }
    
    private var movieCategoryList: some View {
        MovieCategoryView(
            genreTabs: viewModel.genresForDiscoveryView,
            selectedGenre: viewModel.selectedGenre,
            action: { genre in
                viewModel.selectedGenre = genre
            }
        )
    }
    
    private var discoveryList: some View {
        DiscoveryListView(
            data: viewModel.dataForAllMovieTab,
            refreshBookmark: { movie in
                viewModel.refreshBookmarked(
                    active: !movie.isBookmarked,
                    movieId: movie.id,
                    selectedMovie: movie
                )
            }
        )
    }
    
    private var rectangle: some View {
        Rectangle()
            .loadingIndicator(isLoading: viewModel.isFetchingNextPage)
            .frame(minHeight: 100)
            .foregroundColor(Color.green)
            .onAppear() {
                viewModel.fetchNextPage()
            }
    }
}
