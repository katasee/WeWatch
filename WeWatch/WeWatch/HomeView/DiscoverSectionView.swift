//
//  DiscoverSectionView.swift
//  WeWatch
//
//  Created by Anton on 19/01/2025.
//

import SwiftUI

internal struct DiscoverSectionView: View {
    
    private let data: Array<MovieCardPreviewModel>
    private let seeMoreButtonAction: @MainActor () -> Void
    private let chooseButtonAction: @MainActor (MovieCardPreviewModel) -> Void
    
    internal init(
        data: Array<MovieCardPreviewModel>,
        seeMoreButtonAction: @escaping @MainActor () -> Void,
        chooseButtonAction: @escaping @MainActor (MovieCardPreviewModel) -> Void
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
        Button("home.see.more.button.title") {
            seeMoreButtonAction()
        }
        .font(.poppinsRegular16px)
        .foregroundColor(.fieryRed)
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
}

