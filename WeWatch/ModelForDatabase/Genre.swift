//
//  GenresTable.swift
//  WeWatch
//
//  Created by Anton on 01/03/2025.
//

import Foundation

internal struct Genre: SQLTable, Identifiable, Sendable, Hashable {
    
    internal let id: String
    internal let title: String
    
    internal init(
        id: String,
        title: String
    ) {
        self.id = id
        self.title = title
    }
    
    public static var tableName: String { "genres" }
    public static var createTableStatement: String {
    """
    CREATE TABLE IF NOT EXISTS \(tableName)(
    id TEXT PRIMARY KEY,
    title TEXT NOT NULL
    );
    """
    }
    public init(row:[String:Any]) throws {
        guard let id = row["id"] as? String,
              let title = row["title"] as? String
        else {
            throw DatabaseError.bind(message: "Missing required fields")
        }
        self.id = id
        self.title = title
    }
    
    public func toDictionary() -> [String: Any] {
        [
            "id": id,
            "title": title
        ]
    }
}
