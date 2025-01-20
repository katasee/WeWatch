//
//  HomeViewPlaceholder.swift
//  WeWatch
//
//  Created by Anton on 29/12/2024.
//

import SwiftUI

internal struct HomeViewPlaceholder: View {
    
    internal var body: some View {
        ZStack {
            Color.accentColor
                .ignoresSafeArea()
            Text("HomeView")
        }
    }
}

#Preview {
    HomeViewPlaceholder()
}
