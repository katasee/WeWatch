//
//  BookmarkView.swift
//  WeWatch
//
//  Created by Anton on 27/01/2025.
//

import SwiftUI

internal struct BookmarkView: View {
    
    @StateObject private var viewModel: BookmarkViewModel
    
    internal init(viewModel: BookmarkViewModel) {
        self._viewModel = .init(wrappedValue: viewModel)
    }
    
    internal var body: some View {
        NavigationView {
            ZStack {
                Color.black
                    .ignoresSafeArea()
                ScrollView {
                    VStack {
                        BookmarkListView(
                            searchText: $viewModel.searchText,
                            refreshBookmark: { movie in
                                await viewModel.refreshBookmarked(
                                    active: !movie.isBookmarked,
                                    movieId: movie.id
                                )
                            },
                            data: viewModel.filteredBookmarkedMovie,
                            chooseButtonAction: { isActive in },
                            bookmarkAddAction: { _ in },
                            bookmarkRemoveAction: { movie in
                                await viewModel.removeFromDatabase(movieId: movie.id)
                            },
                            bookmarkRemoveAllMovie: { await viewModel.removeAllMovie()}
                        )
                        .padding(16)
                    }
                    .onAppear {
                        Task { try await viewModel.dataFromDatabase()
                        }
                    }
                }
            }
        }
    }
}

