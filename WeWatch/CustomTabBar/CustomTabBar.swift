//
//  CustomTabBar.swift
//  WeWatch
//
//  Created by Anton on 30/12/2024.
//

import SwiftUI

internal struct CustomTabBar: View {
    
    @Binding private var activeTab: TabViewType
    
    internal init(activeTab: Binding<TabViewType>) {
        self._activeTab = activeTab
    }
    
    internal var body: some View {
        VStack {
            HStack {
                ForEach(TabViewType.allCases, id: \.self) { tabType in
                    Spacer()
                    Button(action: {
                        activeTab = tabType
                    }) {
                        tabType.icon(isActive: activeTab == tabType)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(maxWidth: 15, maxHeight: 15)
                    }
                    Spacer()
                }
            }
            .frame(maxHeight: 35)
            .frame(maxWidth: .infinity)
            .background(Color.black)
        }
    }
}
