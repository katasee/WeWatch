//
//  TableForTodaySelectionHomeView.swift
//  WeWatch
//
//  Created by Anton on 27/02/2025.
//

import Foundation

internal struct List: SQLTable, Identifiable, Sendable {
    
    internal let id: String
    internal let title: String
    
    internal init (
        id: String,
        title: String
    ) {
        self.id = id
        self.title = title
    }
    
    internal static var tableName: String { "lists" }
    
    internal static var createTableStatement: String {
        SQLStatements.createListsTableSQL
    }
    
    internal init(row: Dictionary<String, Any>) throws {
        guard let id = row["id"] as? String,
              let title = row["title"] as? String
        else {
            throw DatabaseError.bind(message: "Missing required fields")
        }
        self.id = id
        self.title = title
    }
    
    internal func toDictionary() -> Dictionary<String, Any> {
        [
            "id": id as Any,
            "title": title
        ]
    }
}
