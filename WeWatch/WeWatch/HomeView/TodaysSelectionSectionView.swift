//
//  TodaysSelectionSectionView.swift
//  WeWatch
//
//  Created by Anton on 19/01/2025.
//

import SwiftUI

internal struct TodaysSelectionSectionView: View {
    
    private let data: [Movie]
    private let chooseButtonAction: @MainActor (Movie) -> Void
    
    internal init(
        data: [Movie],
        chooseButtonAction: @escaping @MainActor (Movie) -> Void
    ) {
        self.data = data
        self.chooseButtonAction = chooseButtonAction
    }
    
    internal var body: some View {
        
        VStack {
            HStack {
                title
                Spacer()
            }
            ScrollView(.horizontal, showsIndicators: true) {
                HStack(spacing: 20) {
                    movieCardButton
                }
            }
        }
    }
    
    private var title: some View {
        Text("todaySelection.title")
            .foregroundColor(.whiteColor)
            .font(.poppinsBold30px)
        + Text(". ")
            .foregroundColor(.fieryRed)
            .font(.poppinsBold30px)
    }
    
    private var movieCardButton: some View {
        ForEach(data) { model in
            Button {
                chooseButtonAction(model)
            } label: {
                NavigationLink(destination: DetailsView(viewModel: DetailsViewModel(detailsForMovie: model, movieId: model.id))) {
                    MovieCardTopFive(
                        title: model.title,
                        ranking: Double(model.rating),
                        image: URL(string: model.posterUrl),
                        didTap: { isActive in }
                    )
                }
            }
        }
    }
}
