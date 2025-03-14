//
//  DiscoveryView.swift
//  WeWatch
//
//  Created by Anton on 16/02/2025.
//

import SwiftUI

internal struct DiscoveryView: View {
    
    @StateObject private var viewModel: DiscoveryViewModel
    
    internal init(
        viewModel: DiscoveryViewModel
        
    ) {
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
                    LazyVStack {
                        DiscoveryListView(
                            data: viewModel.dataForAllMovieTab,
                            chooseButtonAction: { isActive in }
                        )
                        Rectangle()
                            .frame(minHeight: 1)
                            .foregroundColor(Color.clear)
                            .onAppear {
                                Task {
                                    viewModel.fetchNextPage()
                                    viewModel.isFirstTimeLoad = false
                                }
                            }
                    }
                }
            }
            .onChange(of: viewModel.selectedGenre) { change in
                Task {
                    viewModel.isFirstTimeLoad = true
                    await viewModel.movieForDiscoveryView()
                }
            }
        }
        .task {
            await viewModel.dataFromEndpointForGenreTabs()
            await viewModel.movieForDiscoveryView()
        }
    }
}
