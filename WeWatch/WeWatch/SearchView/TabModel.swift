//
//  TabModel.swift
//  WeWatch
//
//  Created by Anton on 22/01/2025.
//

import Foundation

internal struct CategoryModel: Identifiable {
    
    private(set) var id: Tab
    
    internal enum Tab: String, CaseIterable {
        case All
        case Animation
        case Action
        case Comedy
        case etc
    }
}
