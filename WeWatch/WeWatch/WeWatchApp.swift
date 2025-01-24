//
//  WeWatchApp.swift
//  WeWatch
//
//  Created by Anton on 22/11/2024.
//

import SwiftUI

@main
internal struct WeWatchApp: App {
    
    @State private var searchText: String = ""
    
    internal var body: some Scene {
        WindowGroup {
            TabBar(searchText: $searchText) 
        }
    }
}

