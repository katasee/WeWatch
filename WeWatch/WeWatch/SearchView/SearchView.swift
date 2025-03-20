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
                    LazyVStack {
                        SearchListView(
                            searchText: $viewModel.searchText,
                            didTap: true,
                            selectedGenre: viewModel.selectedGenre,
                            setOfGenre: viewModel.genresForSearchView,
                            data: viewModel.filteredMovie,
                            isActive: true,
                            selectGenreAction: { genre in viewModel.selectedGenre = genre },
                            seeMoreButtonAction: {},
                            chooseButtonAction: { isActive in }
                        )
                        .padding(16)
                        Rectangle()
                            .frame(minHeight: 1)
                            .foregroundColor(Color.clear)
                            .onAppear {
                                Task { try await viewModel.appendDateFromEndpoint()}
                            }
                        if viewModel.dataForSearchView.isEmpty {
                            ContentUnavailableView.search(text: viewModel.searchText)
                                .foregroundColor(.whiteColor)
                            
                        }
                    }
                }
                .onChange(of: viewModel.searchText) { change in
                    Task {
                        await viewModel.dataFromEndpoint()
                    }
                }
                .onChange(of: viewModel.selectedGenre) { change in
                    Task {
                        await viewModel.dataFromEndpoint()
                    }
                }
                .task {
                    await viewModel.dataFromEndpointForGenreTabs()
                }
            }
        }
    }
}
