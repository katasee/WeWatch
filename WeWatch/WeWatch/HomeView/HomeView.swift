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
                            chooseButtonAction: { isActive in },
                            bookmarkAddAction: {_ in },
                            bookmarkRemoveAction: {_ in }
                        )
                        DiscoverSectionView(
                            data: viewModel.discoverySection,
                            seeMoreButtonAction: {},
                            chooseButtonAction: { isActive in },
                            refreshBookmart: { movie in
                                await viewModel.refreshBookmarked(
                                    active: !movie.isBookmarked,
                                    movieId: movie.id
                                )
                            },
                            bookmarkAddAction: { movie in
                                await viewModel.inserToDatabase(movieId: movie.id)},
                            bookmarkRemoveAction: { movie in
                                await viewModel.removeFromDatabase(movieId: movie.id)
                            }
                        )
                        if !viewModel.discoverySection.isEmpty {
                            Rectangle()
                                .frame(minHeight: 1)
                                .foregroundColor(Color.clear)
                                .onAppear {
                                    Task { try await viewModel.appendDateFromEndpoint()}
                                }
                        }
                    }
                }
                .task {
                    do {
                        try await viewModel.movieForDiscoveryView()
                        try await viewModel.dataForTodaySelection()
                    } catch {
                        print(error)
                    }
                }
                .padding(16)
            }
        }
    }
}
