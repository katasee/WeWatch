//
//  HomeView.swift
//  WeWatch
//
//  Created by Anton on 18/01/2025.
//

import SwiftUI

internal struct HomeView: View {
    
    internal var body: some View {
        ZStack {
            Color(.black)
                .ignoresSafeArea()
            VStack {
                TodaySelctionViewModel()
                DiscoveryViewModel()
            }
            .padding(16)
        }
    }
}

#Preview {
    HomeView()
}
