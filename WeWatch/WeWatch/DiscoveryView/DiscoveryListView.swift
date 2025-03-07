//
//  DiscoveryListView.swift
//  WeWatch
//
//  Created by Anton on 16/02/2025.
//

import SwiftUI

internal struct DiscoveryListView: View {
    
    private let dataForAllMovies: Array<Movie>
    private let chooseButtonAction: @MainActor (Movie) -> Void
    private let selectedGenre: Genre
    private let setOfGenre: Array<Genre>
    private let selectGenreAction: (Genre) -> Void
    
    internal init(
        data: Array<Movie>,
        chooseButtonAction: @escaping @MainActor (Movie) -> Void,
        selectedGenre: Genre,
        setOfGenre: Array<Genre>,
        selectGenreAction: @escaping (Genre) -> Void
    ) {
        self.dataForAllMovies = data
        self.chooseButtonAction = chooseButtonAction
        self.selectedGenre = selectedGenre
        self.setOfGenre = setOfGenre
        self.selectGenreAction = selectGenreAction
    }
    
    internal var body: some View {
        ZStack {
            Color.blackColor
                .ignoresSafeArea()
            VStack(alignment: .leading) {
                categoryTabBar
                allMovie
            }
        }
    }
    
    private var categoryTabBar: some View {
        MovieCategoryView(genreTabs: Array(setOfGenre),
                          selectedGenre: selectedGenre,
                          action: { genre in
            selectGenreAction(genre)
        }
        )
    }
    
    private var allMovie: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())]) {
            ForEach(dataForAllMovies) { model in
                Button {
                    chooseButtonAction(model)
                } label: {
                    NavigationLink(destination: DetailsView()) {
                        MovieCardDiscover(
                            isActive: false,
                            title: model.title,
                            ranking: Double(model.rating),
                            imageUrl:URL(string: model.posterUrl),
                            didTap: { isActive in }
                        )
                    }
                }
            }
        }
    }
}
