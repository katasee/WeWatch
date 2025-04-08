//
//  Movies.swift
//  WeWatch
//
//  Created by Anton on 25/02/2025.
//

import Foundation

internal struct Movie: SQLTable, Identifiable, Sendable, Equatable {
    
    var isBookmarked: Bool = false
    
    internal let id: String
    internal let title: String
    internal let overview: String
    internal let rating: Double
    internal let posterUrl: String
    internal let genres: String
    
    internal init(
        id: String,
        title: String,
        overview: String,
        rating: Double,
        posterUrl: String,
        genres: String
    ) {
        self.id = id
        self.title = title
        self.overview = overview
        self.rating = rating
        self.posterUrl = posterUrl
        self.genres = genres
    }
    
    internal static var tableName: String { "movies" }
    
    internal static var createTableStatement: String {
        SQLStatements.createMoviesTableSQL
    }
    
    internal init(row: Dictionary<String, Any>) throws {
        guard let id = row["id"] as? String,
              let title = row["title"] as? String,
              let overview = row["overview"] as? String,
              let rating = row["rating"] as? Double,
              let posterUrl = row["posterUrl"] as? String,
              let genres = row["genres"] as? String
        else {
            throw DatabaseError.bind(message: "Missing required fields")
        }
        self.id = id
        self.title = title
        self.overview = overview
        self.rating = rating
        self.posterUrl = posterUrl
        self.genres = genres
    }
    
    internal func toDictionary() -> Dictionary<String, Any> {
        [
            "id": id,
            "title": title,
            "overview": overview,
            "rating": rating,
            "posterUrl": posterUrl,
            "genres": genres
        ]
    }
}
