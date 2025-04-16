//
//  KeychainErrors.swift
//  WeWatch
//
//  Created by Anton on 16/04/2025.
//

import Foundation

internal enum KeychainError: Error {
    
    case duplicateItem
    case unknown(OSStatus)
    case itemNotFound
    case unexpectedDataFormat
}
