//
//  DiscoverSectionView.swift
//  WeWatch
//
//  Created by Anton on 19/01/2025.
//

import SwiftUI

internal struct DiscoverSectionView: View {
    
    private let data: Array<Movie>
    private let seeMoreButtonAction: @MainActor () -> Void
    private let chooseButtonAction: @MainActor (Movie) -> Void
    
    internal init(
        data: Array<Movie>,
        seeMoreButtonAction: @escaping @MainActor () -> Void,
        chooseButtonAction: @escaping @MainActor (Movie) -> Void
    ) {
        self.data = data
        self.seeMoreButtonAction = seeMoreButtonAction
        self.chooseButtonAction = chooseButtonAction
    }
    
    internal var body: some View {
        VStack {
            HStack {
                title
                Spacer()
                seeMoreButton
            }
            movieCardButton
        }
    }
    
    private var title: some View {
        Text("home.title")
            .foregroundColor(.whiteColor)
            .font(.poppinsBold30px)
        + Text(". ")
            .foregroundColor(.fieryRed)
            .font(.poppinsBold30px)
    }
    
    private var seeMoreButton: some View {
        Button() {
        } label: {
            NavigationLink(
                destination: DiscoveryView(
                    viewModel: DiscoveryViewModel(
                        dbManager: DatabaseManager(
                            dataBaseName: DatabaseConfig.name
                        )
                    )
                )
            ) {
                Text("home.see.more.button.title")
                    .font(.poppinsRegular16px)
                    .foregroundColor(.fieryRed)
            }
        }
    }
    
    private var movieCardButton: some View {
        ForEach(data) { model in
            Button {
                chooseButtonAction(model)
            } label: {
                NavigationLink(destination: DetailsView(viewModel: DetailsViewModel(detailsForMovie: model, movieId: model.id))) {
                    MovieCard(
                        isActive: false,
                        title: model.title,
                        ranking: Double(model.rating),
                        genres: model.genres,
                        storyline: model.overview,
                        imageUrl: URL(string: model.posterUrl),
                        didTap: { isActive in })
                    .multilineTextAlignment(.leading)
                }
            }
        }
    }
}

