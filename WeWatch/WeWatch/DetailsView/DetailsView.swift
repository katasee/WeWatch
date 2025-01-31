//
//  DetailsView.swift
//  WeWatch
//
//  Created by Anton on 28/01/2025.
//

import SwiftUI

internal struct DetailsView: View {
    
    @StateObject private var viewModel: DetailsViewModel = .init()
        
    internal var body: some View {
        ZStack {
            NavigationBarButtons(
                action: {_ in },
                movie: viewModel.dataForDetailsView
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

#Preview {
    DetailsView()
}
