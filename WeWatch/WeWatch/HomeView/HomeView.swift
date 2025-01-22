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
        ZStack {
            Color(.black)
                .ignoresSafeArea()
            ScrollView {
                VStack {
                    TodaysSelectionSectionView(
                        data: viewModel.dataForTodaysSelectionSectionView,
                        chooseButtonAction: { isActive in
                            // noop
                        }
                    )
                    DiscoverSectionView(
                        data: viewModel.dataForDiscoveryPreviewModel,
                        seeMoreButtonAction: {},
                        chooseButtonAction: { isActive in
                            // noop
                        }
                    )
                }
            }
            .onAppear {
                viewModel.prepareDataTodaySelection()
                viewModel.prepareDataDiscovery()
            }
            .padding(16)
        }
    }
}

#Preview {
    HomeView()
}
