//
//  DiscoverSectionView.swift
//  WeWatch
//
//  Created by Anton on 19/01/2025.
//

import SwiftUI

internal struct DiscoverSectionView: View {
    
    private let data: Array<DataMovieCardPreviewModel>
    private let seeMoreButtonAction: @MainActor () -> Void
    private let chooseButtonAction: @MainActor (DataMovieCardPreviewModel) -> Void
    
    internal init(
        data: Array<DataMovieCardPreviewModel>,
        seeMoreButtonAction: @escaping @MainActor () -> Void,
        chooseButtonAction: @escaping @MainActor (DataMovieCardPreviewModel) -> Void
    ) {
        self.data = data
        self.seeMoreButtonAction = seeMoreButtonAction
        self.chooseButtonAction = chooseButtonAction
    }
    
    internal var body: some View {
        VStack {
            HStack {
                Text("home.title")
                    .foregroundColor(.whiteColor)
                    .font(.poppinsBold30px)
                + Text(". ")
                    .foregroundColor(.fieryRed)
                    .font(.poppinsBold30px)
                Spacer()
                Button("home.see.more.button.title") {
                    seeMoreButtonAction()
                }
                .font(.poppinsRegular16px)
                .foregroundColor(.fieryRed)
            }
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
    }
}

#Preview {
    DiscoverSectionView (
        data: DataMovieCardPreviewModel.mock(),
        seeMoreButtonAction: {},
        chooseButtonAction: { isActive in })
}
