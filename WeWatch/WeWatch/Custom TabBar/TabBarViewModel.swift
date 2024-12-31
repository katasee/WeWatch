//
//  TabBarViewModel.swift
//  WeWatch
//
//  Created by Anton on 30/12/2024.
//

import Foundation
import SwiftUI

internal final class TabBarViewModel: ObservableObject {
    
    @Published internal var homeViewIsActive: Bool = true
    @Published internal var searchViewIsActive: Bool = false
    @Published internal var bookmarkViewIsActive: Bool = false
    @Published internal var selectedTab: TabViewType = .homeView
    
    internal enum TabViewType {
        
        case bookmark
        case searchView
        case homeView
        
        internal func activeView() -> AnyView {
            switch self {
            case.bookmark:
                return AnyView(BookmarkView())
            case.searchView:
                return AnyView(SearchView())
            case.homeView:
                return AnyView(HomeView())
            }
        }
    }
    
    internal func selectTab(_ tab: TabViewType) {
        selectedTab = tab
        switch tab {
        case.bookmark:
            bookmarkViewIsActive = true
            homeViewIsActive = false
            searchViewIsActive = false
        case.searchView:
            searchViewIsActive = true
            homeViewIsActive = false
            bookmarkViewIsActive = false
        case.homeView:
            homeViewIsActive = true
            searchViewIsActive = false
            bookmarkViewIsActive = false
        }
    }
    
    internal func homeViewButton() -> Image {
        if homeViewIsActive == true {
            return Image("home-active-icon")
        } else {
            return Image("home-default-icon")
        }
    }
    
    internal func searchViewButton() -> Image {
        if searchViewIsActive == true {
            return Image("search-active-icon")
        } else {
            return Image("search-default-icon")
        }
    }
    
    func bookmarkView() -> Image {
        if bookmarkViewIsActive == true {
            return Image("bookmark-active-icon")
        } else {
            return Image("bookmark-inactive-icon")
        }
    }
}



