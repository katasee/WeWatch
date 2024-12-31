//
//  TabBar.swift
//  WeWatch
//
//  Created by Anton on 30/12/2024.
//

import SwiftUI

private struct TabBar: View {
    
    @StateObject private var viewModel: TabBarViewModel = .init()

    internal var body: some View {
        ZStack {
            viewModel.selectedTab.activeView()
            CustomTabBar(viewModel: viewModel)
                }
            }
        }

#Preview {
    TabBar()
}
