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
//    private let chooseButtonAction: @MainActor (Movie) -> Void
    private let refreshBookmark: @MainActor (Movie) async -> Void
    private let bookmarkAddAction: @MainActor (Movie) async -> Void
    private let bookmarkRemoveAction: @MainActor (Movie) async -> Void
    
    internal init(
        data: Array<Movie>,
        seeMoreButtonAction: @escaping @MainActor () -> Void,
//        chooseButtonAction: @escaping @MainActor (Movie) -> Void,
        refreshBookmark: @escaping @MainActor (Movie) async -> Void,
        bookmarkAddAction: @escaping @MainActor (Movie) async -> Void,
        bookmarkRemoveAction: @escaping @MainActor (Movie) async -> Void
    ) {
        self.data = data
        self.seeMoreButtonAction = seeMoreButtonAction
//        self.chooseButtonAction = chooseButtonAction
        self.refreshBookmark = refreshBookmark
        self.bookmarkAddAction = bookmarkAddAction
        self.bookmarkRemoveAction = bookmarkRemoveAction
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
//                chooseButtonAction(model)
            } label: {
                NavigationLink(
                    destination: DetailsView(
                        viewModel: DetailsViewModel(
                            dbManager: DatabaseManager(
                                dataBaseName: DatabaseConfig.name
                            ),
                            movieId: model.id
                        ))) {
                                MovieCard(
                                    refreshBookmark: refreshBookmark,
                                    movie: model,
                                    didTap: { isActive in
                                        Task {
                                            await refreshBookmark(model)
                                        }
                                    },
                                    bookmarkAddAction: bookmarkAddAction,
                                    bookmarkRemoveAction: bookmarkRemoveAction
                                )
                                .multilineTextAlignment(.leading)
                        }
            }
        }
    }
}

