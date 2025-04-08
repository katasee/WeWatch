//
//  HomeView.swift
//  WeWatch
//
//  Created by Anton on 18/01/2025.
//

import SwiftUI

internal struct HomeView: View {
    
    @StateObject private var viewModel: HomeViewModel
    
    internal init(viewModel: HomeViewModel) {
        self._viewModel = .init(wrappedValue: viewModel)
    }
    
    internal var body: some View {
        NavigationView {
            ZStack {
                Color.blackColor
                    .ignoresSafeArea()
                VStack {
                    ScrollView {
                        todaySelection
                        discoverySection
                    }
                    .onLoad() {
                        Task {
                            await viewModel.fetchData()
                        }
                    }
                    .padding(16)
                }
                .fullScreenErrorPopUp(error: $viewModel.error, onRetry: {
                    Task {
                        if viewModel.fetchDataError == true {
                            await viewModel.fetchData()
                            viewModel.fetchDataError = false
                        } else if viewModel.appendDataError == true {
                            viewModel.appendDataFromEndpoint()
                            viewModel.appendDataError = false
                        }
                    }
                })
                .fullScreenLoader(isLoading: viewModel.isLoading)
            }
        }
    }
    private var todaySelection: some View {
        TodaysSelectionSectionView(
            data: viewModel.todaySelection,
            refreshBookmark: { movie in
                viewModel.refreshBookmarkedinTodaySelection(
                    active: !movie.isBookmarked,
                    movieId: movie.id
                )
            }
        )
    }
    
    private var discoverySection: some View {
        DiscoverSectionView(
            dataForAllMovies: viewModel.discoverySection,
            seeMoreButtonAction: {},
            refreshBookmark: { movie in
                viewModel.refreshBookmarked(
                    active: !movie.isBookmarked,
                    movieId: movie.id, selectedMovie: movie
                )
            },
            loadMore: { viewModel.appendDataFromEndpoint() },
            isLoading: viewModel.isFetchingNextPage
        )
    }
}
