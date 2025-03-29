//
//  TodaysSelectionSectionView.swift
//  WeWatch
//
//  Created by Anton on 19/01/2025.
//

import SwiftUI

internal struct TodaysSelectionSectionView: View {
    
    private let data: Array<Movie>
    private let refreshBookmark: @MainActor (Movie) async -> Void
    
    internal init(
        data: Array<Movie>,
        refreshBookmark: @escaping @MainActor (Movie) async -> Void
    ) {
        self.data = data
        self.refreshBookmark = refreshBookmark
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
            } label: {
                NavigationLink(
                    destination: DetailsView(
                        viewModel: DetailsViewModel(movieId: model.id)
                    )
                ) {
                    MovieCardTopFive(
                        refreshBookmark: refreshBookmark,
                        movie: model,
                        didTap: { isActive in
                            Task {
                                await refreshBookmark(model)
                            }
                        }
                    )
                }
            }
        }
    }
}
