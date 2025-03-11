//
//  DiscoveryViewModelManager.swift
//  WeWatch
//
//  Created by Anton on 17/02/2025.
//

import Foundation

internal struct MovieForDiscoveryView: Identifiable, Sendable {
    
    internal var id: String
    internal var title: String
    internal var rating: Int
    internal var image: String
    
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
