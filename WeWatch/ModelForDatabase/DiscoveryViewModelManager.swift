//
//  DiscoveryViewModelManager.swift
//  WeWatch
//
//  Created by Anton on 17/02/2025.
//

import Foundation

internal struct MovieForDiscoveryView: Identifiable, Sendable {
    
    internal let id: String
    internal let title: String
    internal let rating: Int
    internal let image: String
    
    internal init(
        id: String,
        title: String,
        rating: Int,
        image: String
    ) {
        self.id = id
        self.title = title
        self.rating = rating
        self.image = image
    }
}
