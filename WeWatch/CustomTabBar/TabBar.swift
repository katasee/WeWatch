//
//  TabBar.swift
//  WeWatch
//
//  Created by Anton on 30/12/2024.
//

import SwiftUI

internal struct TabBar: View {
    
    @StateObject private var viewModel: TabBarViewModel = .init()
    
    internal var body: some View {
        VStack(spacing: .zero) {
            viewForSeletedTab()
            CustomTabBar(activeTab: $viewModel.selectedTab)
        }
    }
    
    @ViewBuilder
    internal func viewForSeletedTab() -> some View {
        switch viewModel.selectedTab {
        case .bookmark:
            BookmarkView(
                viewModel: BookmarkViewModel()
            )
        case .homeView:
            HomeView(
                viewModel: HomeViewModel()
            )
        case .searchView:
            SearchView(
                viewModel: SearchViewModel()
            )
        }
    }
}
