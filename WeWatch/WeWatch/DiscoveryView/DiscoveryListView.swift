//
//  DiscoveryListView.swift
//  WeWatch
//
//  Created by Anton on 16/02/2025.
//

import SwiftUI

internal struct DiscoveryListView: View {
    
    private let data: Array<DiscoveryPreviewModel>
    private let chooseButtonAction: @MainActor (DiscoveryPreviewModel) -> Void
    private let selectedGenre: Genre
    private let setOfGenre: Array<Genre>
    private let selectGenreAction: (Genre) -> Void
    
    internal init(
        data: Array<DiscoveryPreviewModel>,
        chooseButtonAction: @escaping @MainActor (DiscoveryPreviewModel) -> Void,
        selectedGenre: Genre,
        setOfGenre: Array<Genre>,
        selectGenreAction: @escaping (Genre) -> Void
    ) {
        self.data = data
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
                VStack(spacing: 20) {
                    categoryTabBar
                    movies
                }
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
    
    private var movies: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())]) {
                ForEach(data) { model in
                    Button {
                        chooseButtonAction(model)
                    } label: {
                        NavigationLink(destination: DetailsView()) {
                            MovieCardDiscover(title: model.title, ranking: model.rating, imageUrl: model.image)
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    DiscoveryListView(data: [
        DiscoveryPreviewModel(id: 1, title: "Inception", rating: 8.8, image: URL(string: "https://m.media-amazon.com/images/M/MV5BZjFhZmU5NzUtZTg4Zi00ZjRjLWI0YmQtODk2MzI4YjNhYTdkXkEyXkFqcGc@._V1_FMjpg_UX1000_.jpg")),
        DiscoveryPreviewModel(id: 2, title: "Inception", rating: 8.8, image: URL(string: "https://m.media-amazon.com/images/M/MV5BZjFhZmU5NzUtZTg4Zi00ZjRjLWI0YmQtODk2MzI4YjNhYTdkXkEyXkFqcGc@._V1_FMjpg_UX1000_.jpg")),
        DiscoveryPreviewModel(id: 3, title: "Inception", rating: 8.8, image: URL(string: "https://m.media-amazon.com/images/M/MV5BZjFhZmU5NzUtZTg4Zi00ZjRjLWI0YmQtODk2MzI4YjNhYTdkXkEyXkFqcGc@._V1_FMjpg_UX1000_.jpg")),
        DiscoveryPreviewModel(id: 4, title: "Inception", rating: 8.8, image: URL(string: "https://m.media-amazon.com/images/M/MV5BZjFhZmU5NzUtZTg4Zi00ZjRjLWI0YmQtODk2MzI4YjNhYTdkXkEyXkFqcGc@._V1_FMjpg_UX1000_.jpg")),
        DiscoveryPreviewModel(id: 5, title: "Inception", rating: 8.8, image: URL(string: "https://m.media-amazon.com/images/M/MV5BZjFhZmU5NzUtZTg4Zi00ZjRjLWI0YmQtODk2MzI4YjNhYTdkXkEyXkFqcGc@._V1_FMjpg_UX1000_.jpg")),
        DiscoveryPreviewModel(id: 6, title: "Inception", rating: 8.8, image: URL(string: "https://m.media-amazon.com/images/M/MV5BZjFhZmU5NzUtZTg4Zi00ZjRjLWI0YmQtODk2MzI4YjNhYTdkXkEyXkFqcGc@._V1_FMjpg_UX1000_.jpg")),
        
    ],
                      chooseButtonAction: { _ in }, selectedGenre: Genre(title: "Comedy"), setOfGenre: [ Genre(title: "Comedy"), Genre(title: "Horror"), Genre(title: "Action")],  selectGenreAction: { _ in } )
}
