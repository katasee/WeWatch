//
//  ModelDiscoveryData.swift
//  WeWatch
//
//  Created by Anton on 19/01/2025.
//

import Foundation

internal struct ModelDiscoveryData: Identifiable, Sendable {
    
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
    
    internal static func discoveryData() -> [ModelDiscoveryData] {
        [ModelDiscoveryData(
            id: 1,
            title: "Hitman’s Wife’s Bodyguard",
            rating: 3.5,
            genres: "Action, Comedy, Crime",
            storyline: "The world's most lethal odd couple - bodyguard Michael Bryce and hitman Darius Kincaid - are back on anoth......",
            image: URL(string: "https://m.media-amazon.com/images/M/MV5BZjFhZmU5NzUtZTg4Zi00ZjRjLWI0YmQtODk2MzI4YjNhYTdkXkEyXkFqcGc@._V1_FMjpg_UX1000_.jpg"
                      )),
         ModelDiscoveryData(
            id: 3,
            title: "Film 2",
            rating: 3.5,
            genres: "Action, Comedy, Crime",
            storyline: "The world's most lethal odd couple - bodyguard Michael Bryce and hitman Darius Kincaid - are back on anoth......",
            image: URL(string: "https://upload.wikimedia.org/wikipedia/en/6/67/The_Apprentice_%282024_film%29_poster.jpg"
                      )),
         ModelDiscoveryData(
            id: 4,
            title: "Film 3",
            rating: 3.5,
            genres: "Action, Comedy, Crime",
            storyline: "The world's most lethal odd couple - bodyguard Michael Bryce and hitman Darius Kincaid - are back on anoth......",
            image: URL(string: "https://m.media-amazon.com/images/M/MV5BZjFhZmU5NzUtZTg4Zi00ZjRjLWI0YmQtODk2MzI4YjNhYTdkXkEyXkFqcGc@._V1_FMjpg_UX1000_.jpg"
                      )),
         ModelDiscoveryData(
            id: 5,
            title: "Film 4",
            rating: 3.5,
            genres: "Action, Comedy, Crime",
            storyline: "The world's most lethal odd couple - bodyguard Michael Bryce and hitman Darius Kincaid - are back on anoth......",
            image: URL(string: "https://m.media-amazon.com/images/M/MV5BZjFhZmU5NzUtZTg4Zi00ZjRjLWI0YmQtODk2MzI4YjNhYTdkXkEyXkFqcGc@._V1_FMjpg_UX1000_.jpg"
                      )),
         ModelDiscoveryData(
            id: 6,
            title: "Film 5",
            rating: 3.5,
            genres: "Action, Comedy, Crime",
            storyline: "The world's most lethal odd couple - bodyguard Michael Bryce and hitman Darius Kincaid - are back on anoth......",
            image: URL(string: "https://m.media-amazon.com/images/M/MV5BZjFhZmU5NzUtZTg4Zi00ZjRjLWI0YmQtODk2MzI4YjNhYTdkXkEyXkFqcGc@._V1_FMjpg_UX1000_.jpg"
                      )),
         ModelDiscoveryData(
            id: 7,
            title: "Film 6",
            rating: 3.5,
            genres: "Action, Comedy, Crime",
            storyline: "The world's most lethal odd couple - bodyguard Michael Bryce and hitman Darius Kincaid - are back on anoth......",
            image: URL(string: "https://m.media-amazon.com/images/M/MV5BZjFhZmU5NzUtZTg4Zi00ZjRjLWI0YmQtODk2MzI4YjNhYTdkXkEyXkFqcGc@._V1_FMjpg_UX1000_.jpg"
                      ))
        ]
    }
}
