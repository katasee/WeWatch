//
//  SearchListView.swift
//  WeWatch
//
//  Created by Anton on 23/01/2025.
//

import SwiftUI

internal struct SearchListView: View {
    
    private let didTap: Bool
    private let selectedGenre: Genre
    private let selectGenreAction: (Genre) -> Void
    private let setOfGenre: Array<Genre>
    private let data: Array<DataMovieCardPreviewModel>
    private let seeMoreButtonAction: @MainActor () -> Void
    private let chooseButtonAction: @MainActor (DataMovieCardPreviewModel) -> Void
    private var isActive: Bool
    @Binding private var searchText: String
    
    internal init(
        didTap: Bool,
        setOfGenre: Array<Genre>,
        selectedGenre: Genre,
        selectGenreAction: @escaping (Genre) -> Void,
        data: Array<DataMovieCardPreviewModel>,
        seeMoreButtonAction: @escaping @MainActor () -> Void,
        chooseButtonAction: @escaping @MainActor (DataMovieCardPreviewModel) -> Void,
        isActive: Bool,
        searchText: Binding<String>
    ) {
        self.didTap = didTap
        self.setOfGenre = setOfGenre
        self.data = data
        self.selectedGenre = selectedGenre
        self.selectGenreAction = selectGenreAction
        self.seeMoreButtonAction = seeMoreButtonAction
        self.chooseButtonAction = chooseButtonAction
        self.isActive = isActive
        self._searchText = searchText
    }
    
    internal var body: some View {
        titleView
        VStack(alignment: .leading) {
            SearchBar(searchText: $searchText)
            categoryTabBar
            searchResult
            movieCardButton
        }
    }
    
    private var titleView: some View {
         HStack {
                Text("search.title")
                    .foregroundColor(.whiteColor)
                    .font(.poppinsBold30px)
                + Text(".")
                    .foregroundColor(.fieryRed)
                    .font(.poppinsBold30px)
                Spacer()
            }
    }
    
    private var searchResult: some View {
        Text("search.result")
            .font(.poppinsBold18px)
            .foregroundColor(.whiteColor)
        + Text(" \(data.count)")
            .font(.poppinsBold18px)
            .foregroundColor(.whiteColor)
    }
    
    private var movieCardButton: some View {
        ForEach(data) { model in
            Button {
                chooseButtonAction(model)
            } label: {
                MovieCard(
                    title: model.title,
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
    
    private var categoryTabBar: some View {
        MovieCategoryView(
            genreTabs: Array(setOfGenre),
            selectedGenre: selectedGenre,
            action: { genre in
                selectGenreAction(genre)
            }
        )
    }
}

#Preview {
    @Previewable @State var text: String = ""
    SearchListView(
        didTap: true,
        setOfGenre: [],
        selectedGenre: .init(title: ""),
        selectGenreAction: {_ in },
        data: DataMovieCardPreviewModel.mock(),
        seeMoreButtonAction: {},
        chooseButtonAction: { isActive in },
        isActive: true, searchText: $text
    )
}
