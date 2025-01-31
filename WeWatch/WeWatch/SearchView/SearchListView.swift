//
//  SearchListView.swift
//  WeWatch
//
//  Created by Anton on 23/01/2025.
//

import SwiftUI

internal struct SearchListView: View {
    
    @Binding private var searchText: String
    private let didTap: Bool
    private let selectedGenre: Genre
    private let setOfGenre: Array<Genre>
    private let data: Array<MovieCardPreviewModel>
    private var isActive: Bool
    private let selectGenreAction: (Genre) -> Void
    private let seeMoreButtonAction: @MainActor () -> Void
    private let chooseButtonAction: @MainActor (MovieCardPreviewModel) -> Void
    
    internal init(
        searchText: Binding<String>,
        didTap: Bool,
        selectedGenre: Genre,
        setOfGenre: Array<Genre>,
        data: Array<MovieCardPreviewModel>,
        isActive: Bool,
        selectGenreAction: @escaping (Genre) -> Void,
        seeMoreButtonAction: @escaping @MainActor () -> Void,
        chooseButtonAction: @escaping @MainActor (MovieCardPreviewModel) -> Void
    ) {
        self._searchText = searchText
        self.didTap = didTap
        self.selectedGenre = selectedGenre
        self.setOfGenre = setOfGenre
        self.data = data
        self.isActive = isActive
        self.selectGenreAction = selectGenreAction
        self.seeMoreButtonAction = seeMoreButtonAction
        self.chooseButtonAction = chooseButtonAction
    }
    
    internal var body: some View {
        VStack(spacing: 20) {
            titleView
            VStack(alignment: .leading) {
                SearchBar(searchText: $searchText)
                categoryTabBar
                searchResult
                movieCardButton
            }
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
                NavigationLink(destination: DetailsView()) {
                    MovieCard(
                        isActive: false, title: model.title,
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
