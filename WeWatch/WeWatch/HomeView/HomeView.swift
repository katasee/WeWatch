//
//  HomeView.swift
//  WeWatch
//
//  Created by Anton on 18/01/2025.
//

import SwiftUI

internal struct HomeView: View {
    
    @StateObject private var viewModel: HomeViewModel = .init()
    
//    @State private var movie: DomainModels?
    
    internal var body: some View {
        NavigationView {
            ZStack {
                Color(.black)
                    .ignoresSafeArea()
                ScrollView {
                    VStack {

//                        TodaysSelectionSectionView(
//                            data: viewModel.dataForTodaysSelectionSectionView,
//                            chooseButtonAction: { isActive in }
//                        )
                        DiscoverSectionView(
                            data: viewModel.dataForDiscoveryPreviewModel,
                            seeMoreButtonAction: {},
                            chooseButtonAction: { isActive in }
                        )
                    }
                }
             
                .onAppear{
                    Task{
                        await viewModel.prepareDataTodaySelection(title: viewModel.randomData())
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
