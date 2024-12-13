
//  JWTDecode.swift
//  WeWatch

//  Created by Anton on 09/12/2024.

import Foundation

internal final class JWTDecoder {
    
    internal enum jwtError: Error {
        case decodeFailure
        case decodePartError
        case segmentError
        case payloadError
    }
    
    internal func decode(jwtoken: String) throws -> [String: Any] {
        let segments: [String] = jwtoken.components(separatedBy: ".")
        if segments.count != 3 {
            throw jwtError.segmentError
        }
        return try decodeJWTPart(segments[1])
    }
    
    private func base64Decode(_ value: String) -> Data? {
        var base64: String = value
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        let length: Double = Double(base64.lengthOfBytes(using: String.Encoding.utf8))
        let requiredLength: Double = 4 * ceil(length / 4.0)
        let paddingLength: Double = requiredLength - length
        if paddingLength > 0 {
            let padding: String = "".padding(toLength: Int(paddingLength), withPad: "=", startingAt: 0)
            base64 = base64 + padding
        }
        return Data(base64Encoded: base64, options: .ignoreUnknownCharacters)
    }
    
    private func decodeJWTPart(_ value: String) throws -> [String: Any] {
        guard let bodyData: Data = base64Decode(value) else {
            throw jwtError.decodePartError
        }
        do {
            let json: Any = try JSONSerialization.jsonObject(
                with: bodyData,
                options: []
            )
            guard let payload: [String : Any] = json as? [String: Any] else {
                throw jwtError.payloadError
            }
            return payload
            
        } catch {
            throw jwtError.decodeFailure
        }
    }
}

