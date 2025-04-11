//
//  BookmarkListView.swift
//  WeWatch
//
//  Created by Anton on 27/01/2025.
//

import SwiftUI

internal struct BookmarkListView: View {
    
    @Binding private var searchText: String
    private let refreshBookmark: @MainActor (Movie) -> Void
    private let data: Array<Movie>
    private let chooseButtonAction: @MainActor(Movie) -> Void
    private let bookmarkRemoveAllMovie: @MainActor() async -> Void
    private let results: Int
    
    internal init(
        searchText: Binding<String>,
        refreshBookmark: @escaping @MainActor(Movie) -> Void,
        data: Array<Movie>,
        chooseButtonAction: @escaping @MainActor(Movie) -> Void,
        bookmarkRemoveAllMovie: @escaping @MainActor() async -> Void,
        results: Int
    ) {
        self._searchText = searchText
        self.refreshBookmark = refreshBookmark
        self.data = data
        self.chooseButtonAction = chooseButtonAction
        self.bookmarkRemoveAllMovie = bookmarkRemoveAllMovie
        self.results = results
    }
    
    internal var body: some View {
        VStack(spacing: 5) {
            bookmarkTitle
            SearchBar(searchText: $searchText)
            HStack {
                searchResults
                Spacer()
                cleareAllButton
            }
            ScrollView {
                movieCardButton
            }
        }
    }
    
    private var searchResults: some View {
        Text("search.result")
            .font(.poppinsBold16px)
            .foregroundColor(.whiteColor)
        + Text(" \(results)")
            .font(.poppinsBold16px)
            .foregroundColor(.whiteColor)
    }
    
    private var cleareAllButton: some View {
        Button {
            Task {
                await bookmarkRemoveAllMovie()
            }
        } label: {
            Text("Clear.all.button")
                .font(.poppinsRegular16px)
            Image(systemName: "trash")
                .font(.poppinsRegular16px)
        }
        .foregroundColor(.fieryRed)
    }
    
    private var bookmarkTitle: some View {
            HStack {
                Text("bookmarks.title")
                    .foregroundColor(.whiteColor)
                    .font(.poppinsBold24px)
                + Text(".")
                    .foregroundColor(.fieryRed)
                    .font(.poppinsBold24px)
                Spacer()
            }
        }
    
    private var movieCardButton: some View {
        ForEach(data) { model in
            Button {
                chooseButtonAction(model)
            } label: {
                NavigationLink(
                    destination: DetailsView(
                        viewModel: DetailsViewModel(movieId: model.id)
                    )
                )
                {
                    MovieCard(
                        refreshBookmark: refreshBookmark,
                        movie: model
                    )
                    .multilineTextAlignment(.leading)
                }
            }
        }
    }
}
