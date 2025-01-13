//
//  ModelManager.swift
//  WeWatch
//
//  Created by Anton on 07/01/2025.
//

import Foundation

internal class Movie: Identifiable {
    
    internal var movieId: Int = 0
    internal var title: String = ""
    internal var overview: String = ""
    internal var releaseDate: String = ""
    internal var rating: Int = 0
    internal var posterUrl: String = ""
    
    internal init(movieId: Int, title: String, overview: String, releaseDate: String, rating: Int, posterUrl: String) {
        self.movieId = movieId
        self.title = title
        self.overview = overview
        self.releaseDate = releaseDate
        self.rating = rating
        self.posterUrl = posterUrl
    }
}
