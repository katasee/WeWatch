//
//  TableForTodaySelectionHomeView.swift
//  WeWatch
//
//  Created by Anton on 27/02/2025.
//


import Foundation

public struct List: SQLTable {
    
    public let id: String
    public let title: String
    public init (
        id: String,
        title: String
    ) {
        self.id = id
        self.title = title
    }
    
    public static var tableName: String { "lists" }
    
    public static var createTableStatement: String {
                """
                CREATE TABLE IF NOT EXISTS \(tableName)(
                    id TEXT PRIMARY KEY,
                    title TEXT NOT NULL
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
    }
    
    public func toDictionary() -> [String : Any] {
        [
            "id": id as Any,
            "title": title
        ]
    }
}
