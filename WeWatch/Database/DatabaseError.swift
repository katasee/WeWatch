//
//  DatabaseError.swift
//  WeWatch
//
//  Created by Anton on 16/04/2025.
//

import Foundation

internal enum DatabaseError: Error {
    
    case openDatabase(message: String)
    case createTable(message: String)
    case prepare(message: String)
    case step(message: String)
    case bind(message: String)
    case missingId
    case unknownError
    case transactionError
    case fetchError(message: String)
}
