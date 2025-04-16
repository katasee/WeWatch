//
//  JWTDecoderErrors.swift
//  WeWatch
//
//  Created by Anton on 16/04/2025.
//

import Foundation

internal enum JWTError: Error {
    
    case decodeFailure
    case decodePartError
    case segmentError
    case payloadError
}
