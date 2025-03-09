//
//  HomeView.swift
//  WeWatch
//
//  Created by Anton on 18/01/2025.
//

import SwiftUI

internal struct HomeView: View {
    
    @StateObject private var viewModel: HomeViewModel = .init()
//    internal var isFirstTimeLoad = true
    
    internal var body: some View {
        NavigationView {
            ZStack {
                Color(.black)
                    .ignoresSafeArea()
                ScrollView {
                    LazyVStack {
                        TodaysSelectionSectionView(
                            data: viewModel.todaySelection,
                            chooseButtonAction: { isActive in }
                        )
                        DiscoverSectionView(
                            data: viewModel.discoverySection,
                            seeMoreButtonAction: {},
                            chooseButtonAction: { isActive in }
                        )
                        if !viewModel.discoverySection.isEmpty {
                            Rectangle()
                                .frame(minHeight: 1)
                                .foregroundColor(Color.clear)
                                .onAppear { /*viewModel.isFirstTimeLoad = false*/
                                    Task { try await viewModel.appendDateFromEndpoint()}
                                }
                        }
                    }
                }
                .task {
                    do {
                        try await viewModel.movieForDiscoveryView()
                        try await viewModel.dataForTodaySelection()
                    } catch {
                        
                    }
                }
                .padding(16)
            }
        }
    }
}

#Preview {
    HomeView()
}
