//
//  MovieForDiscoveryView.swift
//  WeWatch
//
//  Created by Anton on 24/02/2025.
//

import Foundation

struct TableForDiscoveryView: SQLTable {
    let id: Int
    let title: String
    let rating: Int
    let posterUrl: String
    init (
        id: Int,
        title: String,
        rating: Int,
        posterUrl: String
    ) {
        self.id = id
        self.title = title
        self.rating = rating
        self.posterUrl = posterUrl
    }
    
    public static var tableName: String { "TableForDiscoveryView" }
    
    public static var createTableStatement: String {
                """
                CREATE TABLE IF NOT EXISTS \(tableName)(
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    title TEXT,
                    rating INTEGER,
                    posterUrl TEXT
                );
        """
    }
    
    public init(row: [String : Any]) throws {
        guard let id = row["id"] as? Int,
         let title = row["title"] as? String,
              let rating = row["rating"] as? Int,
              let posterUrl = row["posterUrl"] as? String
        else {
            throw DatabaseError.bind(message: "Missing required fields")
        }
        self.id = id
        self.title = title
        self.rating = rating
        self.posterUrl = posterUrl
    }
    
    public func toDictionary() -> [String : Any] {
        [
            "id": id as Any,
            "title": title,
            "rating": rating,
            "posterUrl": posterUrl
        ]
    }
}
