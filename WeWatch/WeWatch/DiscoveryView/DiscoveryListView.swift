//
//  DiscoveryListView.swift
//  WeWatch
//
//  Created by Anton on 16/02/2025.
//

import SwiftUI

internal struct DiscoveryListView: View {
    
    private let dataForAllMovies: Array<Movie>
    private let selectedGenre: Genre
    private let setOfGenre: Array<Genre>
    private let selectGenreAction: (Genre) -> Void
    private let chooseButtonAction: @MainActor (Movie) -> Void
    
    internal init(
        data: Array<Movie>,
        selectedGenre: Genre,
        setOfGenre: Array<Genre>,
        selectGenreAction: @escaping @MainActor (Genre) -> Void,
        chooseButtonAction: @escaping @MainActor (Movie) -> Void
        
    ) {
        self.dataForAllMovies = data
        self.selectedGenre = selectedGenre
        self.setOfGenre = setOfGenre
        self.selectGenreAction = selectGenreAction
        self.chooseButtonAction = chooseButtonAction
        
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
        MovieCategoryView(
            genreTabs: Array(setOfGenre),
            selectedGenre: selectedGenre,
            action: { genre in
                selectGenreAction(genre)
            }
        )
    }
    
    private var allMovie: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ]
        ) {
            ForEach(dataForAllMovies) { model in
                Button {
                    chooseButtonAction(model)
                } label: {
                    NavigationLink(destination: DetailsView(viewModel: DetailsViewModel())) {
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
