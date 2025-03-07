//
//  TableForTodaySelectionHomeView.swift
//  WeWatch
//
//  Created by Anton on 27/02/2025.
//


import Foundation

internal struct List: SQLTable {
    
    internal let id: String
    internal let title: String
    let lastUpdated: Int?
    init (
        id: String,
        title: String,
        lastUpdated: Int?
    ) {
        self.id = id
        self.title = title
        self.lastUpdated = lastUpdated
    }
    
    public static var tableName: String { "lists" }
    
    public static var createTableStatement: String {
                """
                CREATE TABLE IF NOT EXISTS \(tableName)(
                    id TEXT PRIMARY KEY,
                    title TEXT NOT NULL,
        last_updated INTEGER

                );
        """
    }
    
    public init(row: [String : Any]) throws {
        guard let id = row["id"] as? String,
              let title = row["title"] as? String
        else {
            throw DatabaseError.bind(message: "Missing required fields")
        }
        self.id = id
        self.title = title
        self.lastUpdated = row["last_updated"] as? Int
    }
    
    public func toDictionary() -> [String : Any] {
        [
            "id": id as Any,
            "title": title,
            "last_updated": lastUpdated as Any
        ]
    }
}
