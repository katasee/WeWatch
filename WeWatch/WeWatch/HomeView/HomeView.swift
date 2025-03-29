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
                ScrollView {
                    LazyVStack {
                        TodaysSelectionSectionView(
                            data: viewModel.todaySelection,
                            refreshBookmark: { movie in
                                Task {
                                    await viewModel.refreshBookmarkedinTodaySelection(
                                        active: !movie.isBookmarked,
                                        movieId: movie.id
                                    )
                                }
                            }
                        )
                        DiscoverSectionView(
                            data: viewModel.discoverySection,
                            seeMoreButtonAction: {},
                            refreshBookmark: { movie in
                                Task {
                                    await viewModel.refreshBookmarked(
                                        active: !movie.isBookmarked,
                                        movieId: movie.id, selectedMovie: movie
                                    )
                                }
                            }
                        )
                        if !viewModel.discoverySection.isEmpty {
                            Rectangle()
                                .loadingIndicator(isLoading: viewModel.isFetchingNextPage)
                                .frame(minHeight: 1)
                                .foregroundColor(Color.clear)
                                .onAppear {
                                    Task {
                                        try await viewModel.appendDateFromEndpoint()
                                    }
                                }
                        }
                    }
                }
                .task {
                    do {
                        try await viewModel.movieForDiscoveryView()
                        try await viewModel.dataForTodaySelection()
                    } catch {
                        print("Error loading data: \(error)")
                    }
                }
                .padding(16)
            }
        }
    }
}
