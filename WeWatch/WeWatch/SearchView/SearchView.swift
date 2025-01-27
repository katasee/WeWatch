//
//  SearchView.swift
//  WeWatch
//
//  Created by Anton on 22/01/2025.
//

import SwiftUI

internal struct SearchView: View {
    
    @StateObject private var viewModel: SearchViewModel = .init()
    
    internal var body: some View {
        ZStack {
            Color(.black)
                .ignoresSafeArea()
            ScrollView {
                SearchListView(
                    searchText: $viewModel.searchText,
                    didTap: true,
                    selectedGenre: viewModel.selectedGenre,
                    setOfGenre: viewModel.setOfGenres,
                    data: viewModel.filteredMovie,
                    isActive: true,
                    selectGenreAction: { genre in viewModel.selectedGenre = genre },
                    seeMoreButtonAction: {},
                    chooseButtonAction: { isActive in }
                )
                .padding(16)
            }
            .onAppear {
                viewModel.prepareDataSearchView()
                viewModel.prepareUniqGenres()
            }
        }
    }
}

#Preview {
    SearchView()
}
