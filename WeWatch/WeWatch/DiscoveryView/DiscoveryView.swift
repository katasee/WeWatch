//
//  DiscoveryView.swift
//  WeWatch
//
//  Created by Anton on 16/02/2025.
//

import SwiftUI

internal struct DiscoveryView: View {
    
    @StateObject private var viewModel: DiscoveryViewModel
    @State private var isLoading = false
    
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
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        Color.clear.frame(height: 16) 
                        LazyVStack {
                            DiscoveryListView(
                                data: viewModel.dataForAllMovieTab,
                                chooseButtonAction: { isActive in },
                                bookmarkAddAction: { movie in
                                    await viewModel.inserToDatabase(movieId: movie.id)
                                },
                                bookmarkRemoveAction: { movie in
                                    await viewModel.removeFromDatabase(movieId: movie.id)
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
                                await fetchData()
                            }
                        }
                    }
                }
            }
            .task {
                await viewModel.dataFromEndpointForGenreTabs()
                await fetchData()
            }
        }
    }
    
    private func fetchData() async {
        isLoading = true
        await viewModel.dataFromEndpoint()
        isLoading = false
    }
}
