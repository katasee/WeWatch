//
//  DiscoveryListView.swift
//  WeWatch
//
//  Created by Anton on 16/02/2025.
//

import SwiftUI

internal struct DiscoveryListView: View {
    
    @MainActor private let dataForAllMovies: Array<Movie>
    private let chooseButtonAction: @MainActor (Movie) -> Void

    internal init(
        data: Array<Movie>,
        chooseButtonAction: @escaping @MainActor (Movie) -> Void

    ) {
        self.dataForAllMovies = data
        self.chooseButtonAction = chooseButtonAction

    }
    
    internal var body: some View {
        ZStack {
            Color.blackColor
                .ignoresSafeArea()
            VStack(alignment: .leading) {
//                categoryTabBar
                    allMovie
            }
        }
    }
    
//    private var categoryTabBar: some View {
//
//    }
    
    private let columns: Array<GridItem> = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    private var allMovie: some View {
        LazyVGrid(columns: columns) {
            ForEach(dataForAllMovies) { model in
                Button {
                    chooseButtonAction(model)
                } label: {
                    NavigationLink(
                        destination: DetailsView(
                            viewModel: DetailsViewModel()
                        )) {
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
