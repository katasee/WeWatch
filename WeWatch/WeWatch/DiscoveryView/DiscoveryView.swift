//
//  DiscoveryView.swift
//  WeWatch
//
//  Created by Anton on 16/02/2025.
//

import SwiftUI

internal struct DiscoveryView: View {
    
    @StateObject private var viewModel: DiscoveryViewModel = .init()
    
    internal var body: some View {
        ZStack {
            BackButton()
            Color.black
                .ignoresSafeArea()
            ScrollView {
                LazyVStack {
                    DiscoveryListView(
                        data: viewModel.dataForAllMovieTab, secondData: viewModel.dataForFilteredMovies,
                        chooseButtonAction: { isActive in },
                        selectedGenre: viewModel.selectedGenre,
                        setOfGenre: viewModel.genresForDiscoveryView,
                        selectGenreAction: { genre in viewModel.selectedGenre = genre }
                    )
                    Rectangle()
                        .frame(minHeight: 1)
                        .foregroundColor(Color.clear)
                        .onAppear { viewModel.isFirstTimeLoad = false
                            Task { viewModel.hasReachedEnd()}
                        }
                }
            }
            .onChange(of: viewModel.selectedGenre) { change in Task {
                viewModel.currentPage = 0
                await viewModel.prepeareDataForFilteredMovies()
            }
            }
        }
        .task {
            await viewModel.prepeareGenreForDiscoveryView()
        }
    }
}




#Preview {
    DiscoveryView()
}
