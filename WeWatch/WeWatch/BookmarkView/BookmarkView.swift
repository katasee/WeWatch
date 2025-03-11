//
//  BookmarkView.swift
//  WeWatch
//
//  Created by Anton on 27/01/2025.
//

import SwiftUI

internal struct BookmarkView: View {
    
    @StateObject private var viewModel: BookmarkViewModel
    
    internal init(viewModel: BookmarkViewModel) {
        self._viewModel = .init(wrappedValue: viewModel)
    }
    
    internal var body: some View {
        NavigationView {
            ZStack {
                Color.black
                    .ignoresSafeArea()
                ScrollView {
                    VStack {
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
