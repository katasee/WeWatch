//
//  MockTodaySelectionData.swift
//  WeWatch
//
//  Created by Anton on 21/01/2025.
//

import Foundation

extension TodaySelectionPreviewModel{
    
    internal static func mock() -> Array<TodaySelectionPreviewModel> {
        [TodaySelectionPreviewModel(
            id: 1,
            title: "From",
            rating: 3.5,
            image: URL(string: "https://cdn.europosters.eu/image/350/182855.jpg"
                      )),
         TodaySelectionPreviewModel(
            id: 2,
            title: "Hitman",
            rating: 3.5,
            image: URL(string: "https://rukminim1.flixcart.com/image/300/300/xif0q/poster/z/i/c/large-m0197-the-batman-movie-poster-18-x-12-inch-300-gsm-original-imaggm4qxkavktxg.jpeg"
                      )),
         TodaySelectionPreviewModel(
            id: 3,
            title: "Batman",
            rating: 4,
            image: URL(string: "https://static.posters.cz/image/350/196934.jpg"
                      )),
         TodaySelectionPreviewModel(
            id: 4,
            title: "Bitcoin",
            rating: 5,
            image: URL(string: "https://rukminim1.flixcart.com/image/300/300/xif0q/poster/l/c/k/small-naruto-poster-for-home-office-and-student-room-wall-original-imahyy92hgfhha24.jpeg"
                      )),
         TodaySelectionPreviewModel(
            id: 5,
            title: "Superman",
            rating: 3,
            image: URL(string: "https://miro.medium.com/v2/resize:fit:4800/format:webp/1*39M4XbHXCTfBenNNqLLyLA@2x.jpeg"
                      ))
        ]
    }
}
