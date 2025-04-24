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
    internal let year: String
    internal let posterUrl: String
    internal let country: String
    internal let genres: String
    
    internal init(
        id: String,
        title: String,
        overview: String,
        year: String,
        posterUrl: String,
        country: String,
        genres: String
    ) {
        self.id = id
        self.title = title
        self.overview = overview
        self.year = year
        self.posterUrl = posterUrl
        self.country = country
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
              let year = row["year"] as? String,
              let posterUrl = row["posterUrl"] as? String,
              let country = row["country"] as? String,
              let genres = row["genres"] as? String
        else {
            throw DatabaseError.bind(message: "Missing required fields")
        }
        self.id = id
        self.title = title
        self.overview = overview
        self.year = year
        self.posterUrl = posterUrl
        self.country = country
        self.genres = genres
    }
    
    internal func toDictionary() -> Dictionary<String, Any> {
        [
            "id": id,
            "title": title,
            "overview": overview,
            "year": year,
            "posterUrl": posterUrl,
            "country": country,
            "genres": genres
        ]
    }
}
