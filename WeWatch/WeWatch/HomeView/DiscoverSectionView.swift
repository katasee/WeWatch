//
//  DiscoverSectionView.swift
//  WeWatch
//
//  Created by Anton on 19/01/2025.
//

import SwiftUI

internal struct DiscoverSectionView: View {
    
    private let data: Array<DiscoveryPreviewModel>
    private let seeMoreButtonAction: @MainActor () -> Void
    private let chooseButtonAction: @MainActor (DiscoveryPreviewModel) -> Void
    
    internal init(
        data: Array<DiscoveryPreviewModel>,
        seeMoreButtonAction: @escaping @MainActor () -> Void,
        chooseButtonAction: @escaping @MainActor (DiscoveryPreviewModel) -> Void
    ) {
        self.data = data
        self.seeMoreButtonAction = seeMoreButtonAction
        self.chooseButtonAction = chooseButtonAction
    }
    
    internal var body: some View {
        HStack {
            Text("home.view.some.key")
                .foregroundColor(.whiteColor)
                .font(.poppinsBold30px)
            + Text(". ")
                .foregroundColor(.fieryRed)
                .font(.poppinsBold30px)
            Spacer()
            Button("SeeMore.button") {
                seeMoreButtonAction()
            }
            .font(.poppinsRegular16px)
            .foregroundColor(.fieryRed)
        }
        ForEach(data) { model in
            Button( action : {chooseButtonAction(model)
            }, label: {
                MovieCard(
                    title: model.title,
                    ranking: model.rating,
                    genres: model.genres,
                    storyline: model.storyline,
                    imageUrl: model.image,
                    didTap: { isActive in }
                )
                .multilineTextAlignment(.leading)
            })
        }
    }
}

#Preview {
    DiscoverSectionView (
        data: [DiscoveryPreviewModel(
            id: 1,
            title: "Hitman’s Wife’s Bodyguard",
            rating: 3.5,
            genres: "Action, Comedy, Crime",
            storyline: "The world's most lethal odd couple - bodyguard Michael Bryce and hitman Darius Kincaid - are back on anoth......",
            image: URL(string: "https://m.media-amazon.com/images/M/MV5BZjFhZmU5NzUtZTg4Zi00ZjRjLWI0YmQtODk2MzI4YjNhYTdkXkEyXkFqcGc@._V1_FMjpg_UX1000_.jpg"
                      ))],
        seeMoreButtonAction: {},
        chooseButtonAction: { isActive in })
}
