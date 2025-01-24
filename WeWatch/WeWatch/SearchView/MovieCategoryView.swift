//
//  MovieCategoryView.swift
//  WeWatch
//
//  Created by Anton on 22/01/2025.
//

import SwiftUI

internal struct MovieCategoryView: View {
    
    @State private var activeTab: CategoryModel.Tab = .All
    @State private var tabs: [CategoryModel] = [
        .init(id: CategoryModel.Tab.All),
        .init(id: CategoryModel.Tab.Animation),
        .init(id: CategoryModel.Tab.Action),
        .init(id: CategoryModel.Tab.Comedy),
        .init(id: CategoryModel.Tab.etc)
    ]
    
    internal var body: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(tabs) { tab in
                    Button(action: {
                        activeTab = tab.id
                    }) {
                        PillButton(title: tab.id.rawValue)
                            .background(activeTab == tab.id ? Color.fieryRed : Color.darkGreyColor)
                            .clipShape(.capsule)
                            .controlSize(.mini)
                    }
                }
            }
        }
    }
}

#Preview {
    MovieCategoryView()
}
