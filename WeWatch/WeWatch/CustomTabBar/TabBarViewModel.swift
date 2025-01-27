//
//  TabBarViewModel.swift
//  WeWatch
//
//  Created by Anton on 30/12/2024.
//

import Foundation
import SwiftUI

internal enum TabViewType: CaseIterable {
    
    case homeView
    case searchView
    case bookmark
    
    internal func icon(isActive: Bool) -> Image {
        switch self {
        case .homeView:
            Image(isActive ? "home-active-icon" : "home-inactive-icon")
        case .bookmark:
            Image(isActive ? "bookmark-active-icon" : "bookmark-inactive-icon")
        case .searchView:
            Image(isActive ? "search-active-icon" : "search-inactive-icon")
        }
    }
}

internal final class TabBarViewModel: ObservableObject {
    
    @Published internal var selectedTab: TabViewType = .homeView
}
