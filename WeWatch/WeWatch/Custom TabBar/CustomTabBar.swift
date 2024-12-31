//
//  CustomTabBar.swift
//  WeWatch
//
//  Created by Anton on 30/12/2024.
//

import SwiftUI

internal struct CustomTabBar: View {
    
    @ObservedObject internal var viewModel: TabBarViewModel = .init()
    
    internal var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button(action: {
                    viewModel.selectTab(.homeView)
                }) {
                    viewModel.homeViewButton()
                        .frame(maxWidth: 25, maxHeight: 25)
                }
                Spacer()
                Button(action: {
                    viewModel.selectTab(.searchView)
                }) {
                    viewModel.searchViewButton()
                        .frame(maxWidth: 25, maxHeight: 25)
                }
                Spacer()
                Button(action: {
                    viewModel.selectTab(.bookmark)
                }) {
                    viewModel.bookmarkView()
                        .frame(maxWidth: 25, maxHeight: 25)
                }
                Spacer()
            }
            .frame(maxHeight: 70)
            .background(Color.black)
        }
    }
}

#Preview {
    CustomTabBar(viewModel: .init())
}
