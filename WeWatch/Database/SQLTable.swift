//
//  SQLTable.swift
//  WeWatch
//
//  Created by Anton on 16/04/2025.
//

import Foundation

internal protocol SQLTable {
    
    static var tableName: String { get }
    static var createTableStatement: String { get }
    
    init(row: Dictionary<String, Any>) throws
    func toDictionary() -> Dictionary<String, Any>
}
