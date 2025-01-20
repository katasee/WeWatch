//
//  DataForTodaySelection.swift
//  WeWatch
//
//  Created by Anton on 19/01/2025.
//

import Foundation

internal struct ModelSelctionData: Identifiable, Sendable {
    
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
    
    internal static func TodaySelctionData() -> [ModelSelctionData] {
        [ModelSelctionData(
            id: 1,
            title: "From",
            rating: 3.5,
            image: URL(string: "https://cdn.europosters.eu/image/350/182855.jpg"
                      )),
         ModelSelctionData(
            id: 2,
            title: "Hitman",
            rating: 3.5,
            image: URL(string: "https://rukminim1.flixcart.com/image/300/300/xif0q/poster/z/i/c/large-m0197-the-batman-movie-poster-18-x-12-inch-300-gsm-original-imaggm4qxkavktxg.jpeg"
                      )),
         ModelSelctionData(
            id: 3,
            title: "Batman",
            rating: 4,
            image: URL(string: "https://static.posters.cz/image/350/196934.jpg"
                      )),
         ModelSelctionData(
            id: 4,
            title: "Bitcoin",
            rating: 5,
            image: URL(string: "https://rukminim1.flixcart.com/image/300/300/xif0q/poster/l/c/k/small-naruto-poster-for-home-office-and-student-room-wall-original-imahyy92hgfhha24.jpeg"
                      )),
         ModelSelctionData(
            id: 5,
            title: "Superman",
            rating: 3,
            image: URL(string: "https://miro.medium.com/v2/resize:fit:4800/format:webp/1*39M4XbHXCTfBenNNqLLyLA@2x.jpeg"
                      ))
        ]
    }
}
