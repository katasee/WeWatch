//
//  BookmarkListView.swift
//  WeWatch
//
//  Created by Anton on 27/01/2025.
//

import SwiftUI

internal struct BookmarkListView: View {
    
    @Binding private var searchText: String
    private let data: Array<MovieCardPreviewModel>
    private let chooseButtonAction: @MainActor (MovieCardPreviewModel) -> Void
    let lineLimit: Int = 3
    
    internal init(
        searchText: Binding<String>,
        data: Array<MovieCardPreviewModel>,
        chooseButtonAction: @escaping @MainActor (MovieCardPreviewModel) -> Void
    ) {
        self._searchText = searchText
        self.data = data
        self.chooseButtonAction = chooseButtonAction
    }
    
    internal var body: some View {
        VStack(spacing: 20) {
            bookmarkTitle
            SearchBar(searchText: $searchText)
            movieCardButton
            Spacer()
        }
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
                NavigationLink(destination: DetailsView()) {
                    MovieCard(
                        isActive: true, title: model.title,
                        ranking: model.rating,
                        genres: model.genres,
                        storyline: model.storyline,
                        imageUrl: model.image,
                        didTap: { isActive in }
                    )
                    .multilineTextAlignment(.leading)
                }
            }
        }
    }
}
