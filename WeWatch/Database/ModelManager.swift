//
//  ModelManager.swift
//  WeWatch
//
//  Created by Anton on 07/01/2025.
//

import Foundation

internal struct Movie: Identifiable, Sendable {
    
    internal var id: Int { movieId }
    internal var movieId: Int
    internal var title: String
    internal var overview: String
    internal var releaseDate: String
    internal var rating: Int
    internal var posterUrl: String
    
    internal init(
        movieId: Int,
        title: String,
        overview: String,
        releaseDate: String,
        rating: Int,
        posterUrl: String
    ) {
        self.movieId = movieId
        self.title = title
        self.overview = overview
        self.releaseDate = releaseDate
        self.rating = rating
        self.posterUrl = posterUrl
    }
    static func dataForTodaySelction() -> [Movie] {
        [Movie (movieId: 1,
                title: "From",
                overview: "Good",
                releaseDate: "today",
                rating: 4,
                posterUrl: "www.facebook.com"),
         Movie (movieId: 2,
                 title: "Avatar",
                 overview: "Good",
                 releaseDate: "today",
                 rating: 3,
                 posterUrl: "www.facebook.com"),
         Movie (movieId: 3,
                 title: "Batman",
                 overview: "Good",
                 releaseDate: "today",
                 rating: 4,
                 posterUrl: "www.facebook.com"),
         Movie (movieId: 4,
                 title: "Bitcoin",
                 overview: "Good",
                 releaseDate: "today",
                 rating: 5,
                 posterUrl: "www.facebook.com"),
         Movie (movieId: 5,
                 title: "Superman",
                 overview: "Good",
                 releaseDate: "today",
                 rating: 3,
                 posterUrl: "www.facebook.com")
         ]
    }
}


