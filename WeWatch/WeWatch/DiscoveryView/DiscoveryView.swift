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
            ScrollView {
                LazyVStack {
                    DiscoveryListView(
                        data: viewModel.dataForAllMovieTab,
                        selectedGenre: viewModel.selectedGenre,
                        setOfGenre: viewModel.genresForDiscoveryView,
                        selectGenreAction: { genre in viewModel.selectedGenre = genre },
                        chooseButtonAction: { isActive in }
                    )
                    Rectangle()
                        .frame(minHeight: 1)
                        .foregroundColor(Color.clear)
                        .onAppear {
                            viewModel.isFirstTimeLoad = false
                            Task {
                                viewModel.fetchNextPage()
                            }
                        }
                }
            }
            .onChange(of: viewModel.selectedGenre) { change in
                Task {
                    viewModel.currentPage = 0
                    await viewModel.movieForDiscoveryView()
                }
            }
        }
        .task {
            await viewModel.dataFromEndpointForGenreTabs()
        }
    }
}
