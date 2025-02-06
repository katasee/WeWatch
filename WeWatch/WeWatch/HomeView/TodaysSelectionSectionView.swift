//
//  TodaysSelectionSectionView.swift
//  WeWatch
//
//  Created by Anton on 19/01/2025.
//

import SwiftUI
import SwiftData

internal struct TodaysSelectionSectionView: View {
    
    private let data: Array<TodaySelectionPreviewModel>
    private let chooseButtonAction: @MainActor (TodaySelectionPreviewModel) -> Void
    
    internal init(
        data: Array<TodaySelectionPreviewModel>,
        chooseButtonAction: @escaping @MainActor (TodaySelectionPreviewModel) -> Void
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
                NavigationLink(destination: DetailsView()) {
                    MovieCardTopFive(
                        title: model.title,
                        ranking: Double(model.rating),
                        image: model.image,
                        didTap: { isActive in }
                    )
                }
            }
        }
    }
}

#Preview {
    TodaysSelectionSectionView(
        data: TodaySelectionPreviewModel.mock(),
        chooseButtonAction: { isActive in }
    )
}
