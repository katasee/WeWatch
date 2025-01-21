//
//  DiscoveryPreviewModel.swift
//  WeWatch
//
//  Created by Anton on 19/01/2025.
//

import Foundation

internal struct DiscoveryPreviewModel: Identifiable, Sendable {
    
    internal var id: Int
    internal var title: String
    internal var rating: Double
    internal var genres: String
    internal var storyline: String
    internal var image: URL?
    
    internal init(
        id: Int,
        title: String,
        rating: Double,
        genres: String,
        storyline: String,
        image: URL?
    ) {
        self.id = id
        self.title = title
        self.rating = rating
        self.genres = genres
        self.storyline = storyline
        self.image = image
    }
}
