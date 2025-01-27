//
//  BookmarkView.swift
//  WeWatch
//
//  Created by Anton on 27/01/2025.
//

import SwiftUI

internal struct BookmarkView: View {
    
    @StateObject private var viewModel: BookmarkViewModel = .init()
    private let isActive: Bool = false
    
    internal var body: some View {
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

#Preview {
    BookmarkView()
}
