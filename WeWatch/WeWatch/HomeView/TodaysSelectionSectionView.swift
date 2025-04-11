//
//  TodaysSelectionSectionView.swift
//  WeWatch
//
//  Created by Anton on 19/01/2025.
//

import SwiftUI

internal struct TodaysSelectionSectionView: View {
    
    private let data: Array<Movie>
    private let refreshBookmark: @MainActor (Movie) -> Void
    
    internal init(
        data: Array<Movie>,
        refreshBookmark: @escaping @MainActor (Movie) -> Void
    ) {
        self.data = data
        self.refreshBookmark = refreshBookmark
    }
    
    internal var body: some View {
        VStack(spacing: 5) {
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
            .font(.poppinsBold24px)
        + Text(". ")
            .foregroundColor(.fieryRed)
            .font(.poppinsBold24px)
    }
    
    private var movieCardButton: some View {
        ForEach(data) { model in
            NavigationLink(
                destination: DetailsView(
                    viewModel: DetailsViewModel(movieId: model.id)
                )
            ) {
                MovieCardTodaySelection(
                    refreshBookmark: refreshBookmark,
                    movie: model
                )
            }
        }
    }
}
