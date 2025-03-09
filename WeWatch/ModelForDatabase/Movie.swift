//
//  Movies.swift
//  WeWatch
//
//  Created by Anton on 25/02/2025.
//

import Foundation

public struct Movie: SQLTable, Identifiable, Sendable {
    
    public let id: String
    public let title: String
    public let overview: String
    public let rating: Double
    public let posterUrl: String
    public let genres: String
    
    public init(
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
    
    public static var tableName: String { "movies" }
    
    public static var createTableStatement: String {
        """
        CREATE TABLE IF NOT EXISTS \(tableName)(
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        overview TEXT,
        rating REAL,
        posterUrl TEXT,
        genres TEXT
    );
"""
    }
    
    public init(row:[String: Any]) throws {
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
    
    public func toDictionary() -> [String: Any] {
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
