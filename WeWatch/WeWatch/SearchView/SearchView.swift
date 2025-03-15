//
//  SearchView.swift
//  WeWatch
//
//  Created by Anton on 22/01/2025.
//

import SwiftUI

internal struct SearchView: View {
    
    @StateObject private var viewModel: SearchViewModel
    
    internal init(viewModel: SearchViewModel) {
        self._viewModel = .init(wrappedValue: viewModel)
    }
       
    internal var body: some View {
        NavigationView {
            ZStack {
                Color.blackColor
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
}
