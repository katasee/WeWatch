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
            DiscoveryListView(
                data: viewModel.dataForAllMovieTab, secondData: viewModel.dataForFilteredMovies,
                chooseButtonAction: { isActive in },
                selectedGenre: viewModel.selectedGenre,
                setOfGenre: viewModel.genresForDiscoveryView,
                selectGenreAction: { genre in viewModel.selectedGenre = genre }
            )
            .onChange(of: viewModel.selectedGenre) { change in Task {
                await viewModel.prepeareDataForFilteredMovies()
            }
            }
        }
        .task {
            await viewModel.prepeareGenreForDiscoveryView()
            await viewModel.prepeareDataForAllMovies()
        }
    }
}




#Preview {
    DiscoveryView()
}
