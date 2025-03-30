//
//  SearchView.swift
//  WeWatch
//
//  Created by Anton on 22/01/2025.
//

import SwiftUI

internal struct SearchView: View {
    
    @StateObject private var viewModel: SearchViewModel
    @State private var isLoading = false
    
    internal init(viewModel: SearchViewModel) {
        self._viewModel = .init(wrappedValue: viewModel)
    }
    
    internal var body: some View {
        NavigationView {
            ZStack {
                Color.blackColor
                    .ignoresSafeArea()
                VStack(spacing: 20) {
                    HStack {
                        Text("search.title")
                            .foregroundColor(.whiteColor)
                            .font(.poppinsBold30px)
                        + Text(".")
                            .foregroundColor(.fieryRed)
                            .font(.poppinsBold30px)
                        Spacer()
                    }
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
                        + Text(" \(viewModel.searchText.count)")
                            .font(.poppinsBold18px)
                            .foregroundColor(.whiteColor)
                    }
                    GeometryReader { proxy in
                        ScrollView {
                            LazyVStack {
                                if viewModel.dataForSearchView.isEmpty {
                                    Spacer()
                                    ContentUnavailableView.search(text: viewModel.searchText)
                                        .foregroundColor(.whiteColor)
                                    Spacer()
                                } else {
                                    SearchListView(
                                        data: viewModel.filteredMovie,
                                        seeMoreButtonAction: {},
                                        refreshBookmark: { movie in
                                            viewModel.refreshBookmarked(
                                                active: !movie.isBookmarked,
                                                movieId: movie.id, selectedMovie: movie
                                            )
                                        }
                                    )
                                    .padding(16)
                                    Rectangle()
                                        .loadingIndicator(isLoading: viewModel.isFetchingNextPage)
                                        .frame(minHeight: 1)
                                        .foregroundColor(Color.clear)
                                        .onAppear {
                                            Task { try await viewModel.appendDateFromEndpoint() }
                                        }
                                }
                            }
                        }
                        .frame(minHeight: proxy.size.height)
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
                }
            }
        }
        .task {
            await viewModel.dataFromEndpointForGenreTabs()
        }
    }
}
