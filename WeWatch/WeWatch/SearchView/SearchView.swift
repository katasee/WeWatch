//
//  SearchView.swift
//  WeWatch
//
//  Created by Anton on 22/01/2025.
//

import SwiftUI

internal struct SearchView: View {
    
    @StateObject private var viewModel: SearchViewModel = .init(searchText: "")
    
    internal var body: some View {
        ZStack {
            Color(.black)
                .ignoresSafeArea()
            ScrollView {
                VStack {
                    SearchListView(
                        didTap: true,
                        setOfGenre: viewModel.setOfGenres,
                        selectedGenre: viewModel.selectedGenre,
                        selectGenreAction: { genre in
                            viewModel.selectedGenre = genre
                        },
                        data: viewModel.filteredMovie,
                        seeMoreButtonAction: {},
                        chooseButtonAction: { isActive in },
                        isActive: true,
                        searchText: $viewModel.searchText
                    )
                }
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
