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
                            .frame(maxWidth: 20, maxHeight: 20)
                    }
                    Spacer()
                }
            }
            .frame(maxWidth: .infinity)
            .frame(maxHeight: 70)
            .background(Color.black)
        }
    }
}

#Preview {
    CustomTabBar(activeTab: .constant(.homeView))
}
