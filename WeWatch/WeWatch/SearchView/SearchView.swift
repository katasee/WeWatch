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
                VStack(spacing: 5) {
                    title
                    searchBar
                    ScrollView {
                        if viewModel.dataForSearchView.isEmpty {
                            Spacer()
                            ContentUnavailableView.search(text: viewModel.searchText)
                                .foregroundColor(.whiteColor)
                            Spacer()
                        } else {
                            searchList
                                .padding(16)
                        }
                    }
                    .onChange(of: viewModel.searchText) { change in
                        Task {
                            await viewModel.fetchData()
                        }
                    }
                    .onLoad() {
                        Task {
                            await viewModel.fetchData()
                        }
                    }
                    
                    .onChange(of: viewModel.selectedGenre) { change in
                        Task {
                            await viewModel.fetchData()
                        }
                    }
                }
                .fullScreenErrorPopUp(error: $viewModel.error, onRetry: {
                    Task {
                        if viewModel.fetchDataError == true {
                            await viewModel.fetchData()
                            viewModel.fetchDataError = false
                        } else if viewModel.appendDataError == true {
                            try await viewModel.appendDataFromEndpoint()
                            viewModel.appendDataError = false
                        }
                    }
                })
                .fullScreenLoader(isLoading: viewModel.isLoading)
            }
        }
        .task {
            await viewModel.dataFromEndpointForGenreTabs()
        }
    }
    
    private var title: some View {
        HStack {
            Text("search.title")
                .foregroundColor(.whiteColor)
                .font(.poppinsBold24px)
            + Text(".")
                .foregroundColor(.fieryRed)
                .font(.poppinsBold24px)
            Spacer()
        }
    }
    
    private var searchBar: some View {
        VStack(alignment: .leading) {
            SearchBar(searchText: $viewModel.searchText)
            MovieCategoryView(
                genreTabs: viewModel.genresForSearchView,
                selectedGenre: viewModel.selectedGenre,
                action: { genre in viewModel.selectedGenre = genre }
            )
            Text("search.result")
                .font(.poppinsBold18px)
                .foregroundColor(.whiteColor)
            + Text(" \(viewModel.dataForSearchView.count)")
                .font(.poppinsBold18px)
                .foregroundColor(.whiteColor)
        }
    }
    
    private var searchList: some View {
        SearchListView(
            dataForAllMovies: viewModel.filteredMovie,
            seeMoreButtonAction: {},
            refreshBookmark: { movie in
                viewModel.refreshBookmarked(
                    active: !movie.isBookmarked,
                    movieId: movie.id, selectedMovie: movie
                )
            },
            loadMore: { viewModel.appendDataFromEndpoint() },
            isLoading: viewModel.isFetchingNextPage
        )
    }
}
