//
//  DiscoveryView.swift
//  WeWatch
//
//  Created by Anton on 16/02/2025.
//

import SwiftUI

internal struct DiscoveryView: View {
    
    @StateObject private var viewModel: DiscoveryViewModel
    @State private var listID = UUID()
    @State private var isLoading = false
    
    internal init(viewModel: DiscoveryViewModel) {
        self._viewModel = .init(wrappedValue: viewModel)
    }
    
    internal var body: some View {
        ZStack {
            BackButton()
            Color.black
                .ignoresSafeArea()
            VStack {
                MovieCategoryView(
                    genreTabs: viewModel.genresForDiscoveryView,
                    selectedGenre: viewModel.selectedGenre,
                    action: { genre in
                        viewModel.selectedGenre = genre
                    }
                )
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVStack {
                            DiscoveryListView(
                                data: viewModel.dataForAllMovieTab,
                                chooseButtonAction: { isActive in }
                            )
                            Rectangle()
                                .frame(minHeight: 16)
                                .foregroundColor(Color.clear)
                                .onAppear {
                                    Task {
                                        await viewModel.fetchNextPage()
                                    }
                                }
                        }
                        .id(listID)
                        .onChange(of: viewModel.selectedGenre) { change in
                            Task {
                                isLoading = true
                                viewModel.isGenreSwitching = true // Блокуємо fetchNextPage
                                await viewModel.movieDataFromEndpoint()
                                listID = UUID() // Прокручуємо нагору
                                viewModel.isGenreSwitching = false // Дозволяємо fetchNextPage знову
                                isLoading = false
                            }
                        }
                    }
                }
            }
            .task {
                isLoading = true
                await viewModel.dataFromEndpointForGenreTabs()
                await viewModel.movieDataFromEndpoint()
                isLoading = false
            }
        }
    }
}


//import SwiftUI
//
//internal struct DiscoveryView: View {
//
//    @StateObject private var viewModel: DiscoveryViewModel
//    @State private var listID = UUID()
//    @State private var isLoading = false
//
//    //    @State private var isFirstLaunch = true
//
//    internal init(
//        viewModel: DiscoveryViewModel
//
//    ) {
//        self._viewModel = .init(wrappedValue: viewModel)
//    }
//
//    internal var body: some View {
//        ZStack {
//            BackButton()
//            Color.black
//                .ignoresSafeArea()
//            VStack {
//                MovieCategoryView(
//                    genreTabs: viewModel.genresForDiscoveryView,
//                    selectedGenre: viewModel.selectedGenre,
//                    action: { genre in
//                        viewModel.selectedGenre = genre
//                    }
//                )
//                if isLoading {
//                    ProgressView()
//                        .progressViewStyle(CircularProgressViewStyle())
//                        .frame(maxWidth: .infinity, maxHeight: .infinity)
//                } else {
//                    ScrollView {
//                        LazyVStack {
//                            DiscoveryListView(
//                                data: viewModel.dataForAllMovieTab,
//                                chooseButtonAction: { isActive in }
//                            )
//                            Rectangle()
//                                .frame(minHeight: 16)
//                                .foregroundColor(Color.clear)
//                                .onAppear {
//                                    Task {
//                                        viewModel.fetchNextPage()
//
//                                        if !viewModel.isFirstTimeLoad {
//                                            listID = UUID() // Прокручуємо нагору після першого завантаження
//                                        }
//                                    }
//                                }
//                        }
//                        .id(listID)
//
//                        .onChange(of: viewModel.selectedGenre) { change in
//                            Task {
//                                isLoading = true
//                                await viewModel.movieDataFromEndpoint()
//                                isLoading = false
//                            }
//                        }
//                    }
//                }
//            }
//            .task {
//                isLoading = true
//                await viewModel.dataFromEndpointForGenreTabs()
//                await viewModel.movieDataFromEndpoint()
//                isLoading = false
//
//            }
//        }
//    }
//}
//
