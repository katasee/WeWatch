//
//  TodaySelectionPreviewModel.swift
//  WeWatch
//
//  Created by Anton on 19/01/2025.
//

import Foundation

internal struct TodaySelectionPreviewModel: Identifiable, Sendable {
    
    internal var id: Int
    internal var title: String
    internal var rating: Double
    internal var image: URL?
    
    internal init(
        id: Int,
        title: String,
        rating: Double,
        image: URL?
    ) {
        self.id = id
        self.title = title
        self.rating = rating
        self.image = image
    }
}
