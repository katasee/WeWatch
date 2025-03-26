//
//  BookmarkListView.swift
//  WeWatch
//
//  Created by Anton on 27/01/2025.
//

import SwiftUI

internal struct BookmarkListView: View {
    
    @Binding private var searchText: String
    private let data: Array<Movie>
    private let chooseButtonAction: @MainActor(Movie) -> Void
    private let bookmarkAddAction: @MainActor(Movie) async -> Void
    private let bookmarkRemoveAction: @MainActor(Movie) async -> Void
    private let bookmarkRemoveAllMovie: @MainActor() async -> Void
    
    internal init(
        searchText: Binding<String>,
        data: Array<Movie>,
        chooseButtonAction: @escaping @MainActor(Movie) -> Void,
        bookmarkAddAction: @escaping @MainActor(Movie) async -> Void,
        bookmarkRemoveAction: @escaping @MainActor(Movie) async -> Void,
        bookmarkRemoveAllMovie: @escaping @MainActor() async -> Void
    ) {
        self._searchText = searchText
        self.data = data
        self.chooseButtonAction = chooseButtonAction
        self.bookmarkAddAction = bookmarkAddAction
        self.bookmarkRemoveAction = bookmarkRemoveAction
        self.bookmarkRemoveAllMovie = bookmarkRemoveAllMovie
    }
    
    internal var body: some View {
        VStack(spacing: 20) {
            bookmarkTitle
            SearchBar(searchText: $searchText)
            HStack {
                Spacer()
                cleareAllButton
            }
            movieCardButton
            Spacer()
        }
    }
    
    private var cleareAllButton: some View {
        Button {
            Task {
                await bookmarkRemoveAllMovie()
            }
        } label: {
            Text("Clear.all.button")
            Image(systemName: "trash")
        }
        .foregroundColor(.fieryRed)
    }
    
    private var bookmarkTitle: some View {
        VStack{
            HStack {
                Text("bookmarks.title")
                    .foregroundColor(.whiteColor)
                    .font(.poppinsBold30px)
                + Text(".")
                    .foregroundColor(.fieryRed)
                    .font(.poppinsBold30px)
                Spacer()
            }
        }
    }
    
    private var movieCardButton: some View {
        ForEach(data) { model in
            Button {
                chooseButtonAction(model)
            } label: {
                NavigationLink(
                    destination: DetailsView(
                        viewModel: DetailsViewModel(
                            dbManager: DatabaseManager(
                                dataBaseName: DatabaseConfig.name
                            ),
                            movieId: model.id
                        )
                    )
                )
                {
                    MovieCard(
                        movie: model,
                        didTap: { isActive in }, refreshBookmart: {_ in},
                        bookmarkAddAction: bookmarkAddAction,
                        bookmarkRemoveAction: bookmarkRemoveAction
                    )
                    .multilineTextAlignment(.leading)
                }
            }
        }
    }
}
