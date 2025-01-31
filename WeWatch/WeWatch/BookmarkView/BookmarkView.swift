//
//  BookmarkView.swift
//  WeWatch
//
//  Created by Anton on 27/01/2025.
//

import SwiftUI

internal struct BookmarkView: View {
    
    @StateObject private var viewModel: BookmarkViewModel = .init()

    internal var body: some View {
        NavigationView {

            ZStack {
                Color.black
                    .ignoresSafeArea()
                VStack {
                    ScrollView {
                        BookmarkListView(
                            searchText: $viewModel.searchText,
                            data: viewModel.filteredBookmarkedMovie,
                            chooseButtonAction: { isActive in }
                        )
                        .padding(16)
                    }
                    .onAppear {
                        viewModel.prepareDataBookmarkView()
                    }
                }
            }
        }
    }
}

#Preview {
    BookmarkView()
}
