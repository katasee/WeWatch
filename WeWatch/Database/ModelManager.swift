//
//  ModelManager.swift
//  WeWatch
//
//  Created by Anton on 07/01/2025.
//

import Foundation

internal struct Movie: Identifiable, Sendable {
    
    internal var id: String { movieId }
    internal var movieId: String
    internal var title: String
    internal var overview: String
    internal var releaseDate: String
    internal var rating: Int
    internal var posterUrl: String
    internal var genres: [String]
    
    internal init(
        movieId: String,
        title: String,
        overview: String,
        releaseDate: String,
        rating: Int,
        posterUrl: String,
        genres: [String]
    ) {
        self.movieId = movieId
        self.title = title
        self.overview = overview
        self.releaseDate = releaseDate
        self.rating = rating
        self.posterUrl = posterUrl
        self.genres = genres
    }
}


