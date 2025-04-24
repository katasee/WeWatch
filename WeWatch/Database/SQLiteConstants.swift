//
//  SQLiteConstants.swift
//  WeWatch
//
//  Created by Anton on 16/04/2025.
//

import Foundation
import SQLite3

internal enum SQLiteConstants {
    
    internal static let sqliteTransient: sqlite3_destructor_type = unsafeBitCast(
        OpaquePointer(
            bitPattern: -1),
        to: sqlite3_destructor_type.self
    )
}
