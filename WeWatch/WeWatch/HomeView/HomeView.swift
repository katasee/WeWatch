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
                        LazyVStack {
                            TodaysSelectionSectionView(
                                data: viewModel.todaySelection,
                                refreshBookmark: { movie in
                                    viewModel.refreshBookmarkedinTodaySelection(
                                        active: !movie.isBookmarked,
                                        movieId: movie.id
                                    )
                                }
                            )
                            DiscoverSectionView(
                                data: viewModel.discoverySection,
                                seeMoreButtonAction: {},
                                refreshBookmark: { movie in
                                    viewModel.refreshBookmarked(
                                        active: !movie.isBookmarked,
                                        movieId: movie.id, selectedMovie: movie
                                    )
                                }
                            )
                            if !viewModel.discoverySection.isEmpty {
                                Rectangle()
                                    .loadingIndicator(isLoading: viewModel.isFetchingNextPage)
                                    .frame(minHeight: 1)
                                    .foregroundColor(Color.clear)
                                    .onAppear {
                                        Task { try await viewModel.appendDataFromEndpoint() }
                                    }
                            }
                        }
                    }
//                    .fullScreenErrorPopUp(error: $viewModel.error, onRetry: {
//                        Task {
//                            if viewModel.fetchDataError == true {
//                                await viewModel.fetchData()
//                                viewModel.fetchDataError = false
//                            } else if viewModel.appendDataError == true {
//                                await viewModel.appendDataFromEndpoint()
//                                viewModel.appendDataError = false
//                            }
//                        }
//                    })
//                    .fullScreenLoader(isLoading: viewModel.isLoading)
                }
                .task {
                    await viewModel.fetchData()
                }
                .padding(16)
            }
        }
    }
}
