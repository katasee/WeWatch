//
//  TableForDiscoveryFilterMovie.swift
//  WeWatch
//
//  Created by Anton on 25/02/2025.
//

import Foundation

struct TableForDiscoveryFilterMovie: SQLTable {
    
    let id: String?
    let title: String
    let overview: String
    let releaseDate: String
    let rating: Int
    let posterUrl: String
    
    public static var tableName: String { "Movies" }
    
    public static var createTableStatement: String {
        """
        CREATE TABLE IF NOT EXISTS \(tableName) (
        id TEXT PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        overview TEXT,
        releaseDate TEXT,
        rating INTEGER,
        posterUrl TEXT
    };
"""
    }
    
    public init(row:[String: Any]) throws {
        self.id = row["id"] as? String
        guard let title = row["title"] as? String,
              let overview = row["overwiew"] as? String,
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
    
    public func toDictionary() -> [String: Any] {
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
//
//struct User: SQLTable {
//    
//    let id: String?
//       let title: String
//       let overview: String
//       let releaseDate: String
//       let rating: Int
//       let posterUrl: String
//
//    
//        public static var tableName: String { "Movies" }
//
//    public static var createTableStatement: String {
//        """
//        CREATE TABLE IF NOT EXISTS \(tableName) (
//            id INTEGER PRIMARY KEY AUTOINCREMENT,
//            name TEXT,
//            email TEXT
//        );
//        """
//    }
//    
//    public init(row: [String : Any]) throws {
//        self.id = row["id"] as? Int
//        guard let name = row["name"] as? String,
//              let email = row["email"] as? String else {
//            throw DatabaseError.bind(message: "Missing required fields")
//        }
//        self.name = name
//        self.email = email
//    }
//    
//    public func toDictionary() -> [String : Any] {
//        [
//            "id": id as Any,
//            "name": name,
//            "email": email
//        ]
//    }
//}
//
//
//
//
//
//
//
//
//
//
//
//
