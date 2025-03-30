//
//  Bookmark.swift
//  WeWatch
//
//  Created by Anton on 27/03/2025.
//

import Foundation

internal struct BookmarkIds: SQLTable, Identifiable, Sendable, Hashable {
    
    internal let id: String
    
    internal init(
        id: String
    ) {
        self.id = id
    }
    
    internal static var tableName: String { "bookmark" }
    internal static var createTableStatement: String {
        SQLStatements.createBookmarkIdsTableSQL
    }
    
    internal init(row: Dictionary<String, Any>) throws {
        guard let id = row["id"] as? String
        else {
            throw DatabaseError.bind(message: "Missing required fields")
        }
        self.id = id
    }
    
    internal func toDictionary() -> Dictionary<String, Any> {
        [
            "id": id,
        ]
    }
}
