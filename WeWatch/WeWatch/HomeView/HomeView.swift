//
//  HomeView.swift
//  WeWatch
//
//  Created by Anton on 18/01/2025.
//

import SwiftUI

internal struct HomeView: View {
    
    @StateObject private var viewModel: HomeViewModel = .init()
    
    internal var body: some View {
        NavigationView {
            ZStack {
                Color(.black)
                    .ignoresSafeArea()
                ScrollView {
                    LazyVStack {
                        TodaysSelectionSectionView(
                            data: viewModel.dataForTodaysSelectionSectionView,
                            chooseButtonAction: { isActive in }
                        )
                        DiscoverSectionView(
                            data: viewModel.dataForDiscoverySectionView,
                            seeMoreButtonAction: {},
                            chooseButtonAction: { isActive in }
                        )
                        if !viewModel.dataForDiscoverySectionView.isEmpty {
                            Rectangle()
                                .frame(minHeight: 1)
                                .foregroundColor(Color.clear)
                                .onAppear { viewModel.isFirstTimeLoad = false
                                    Task { try await viewModel.appendDateFromEndpoint()}
                                }
                        }
                    }
                }
                .task {
                    do {
                        await viewModel.movieForDiscoveryView()
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
