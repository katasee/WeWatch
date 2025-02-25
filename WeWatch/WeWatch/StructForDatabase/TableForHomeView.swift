//
//  TableForHomeView.swift
//  WeWatch
//
//  Created by Anton on 24/02/2025.
//

import Foundation

struct TableForHomeView: SQLTable {
    let id: String?
    let title: String
    let overview: String
    let releaseDate: String
    let rating: Int
    let posterUrl: String
    init (
        id: String,
        title: String,
        overview: String,
        releaseDate: String,
        rating: Int,
        posterUrl: String
    ) {
        self.id = id
        self.title = title
        self.overview = overview
        self.releaseDate = releaseDate
        self.rating = rating
        self.posterUrl = posterUrl
    }
    
    public static var tableName: String { "MovieForHomeView" }
    
    public static var createTableStatement: String {
                """
                CREATE TABLE IF NOT EXISTS MovieForHomeView(
                    id TEXT PRIMARY KEY UNIQUE,
                    title TEXT,
                    overview TEXT,
                    releaseDate TEXT,
                    rating INTEGER,
                    posterUrl TEXT
                );
        """
    }
    
    public init(row: [String : Any]) throws {
        self.id = row["id"] as? String
        guard let title = row["title"] as? String,
              let overview = row["overview"] as? String,
              let releaseDate = row["releaseDate"] as? String,
              let rating = row["rating"] as? Int,
              let posterUrl = row["posterUrl"] as? String
        else {
            throw DatabaseError.bind(message: "Missing required fields")
        }
        self.title = title
        self.overview = overview
        self.releaseDate = releaseDate
        self.rating = rating
        self.posterUrl = posterUrl
    }
    
    public func toDictionary() -> [String : Any] {
        [
            "id": id as Any,
            "title": title,
            "overview": overview,
            "releaseDate": releaseDate,
            "rating": rating,
            "posterUrl": posterUrl
        ]
    }
}
