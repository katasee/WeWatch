//
//  DetailsView.swift
//  WeWatch
//
//  Created by Anton on 28/01/2025.
//

import SwiftUI

internal struct DetailsView: View {
    
    @StateObject private var viewModel: DetailsViewModel
    
    internal init(viewModel: DetailsViewModel) {
        self._viewModel = .init(wrappedValue: viewModel)
    }
        
    internal var body: some View {
        ZStack {
            NavigationBarButtons(
                movie: viewModel.dataForDetailsView, action: {_ in }
            )
            ScrollView {
                VStack {
                    DetailSectionView(movie: viewModel.dataForDetailsView)
                }
            }
        }
        .ignoresSafeArea()
    }
}
