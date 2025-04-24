//
//  Environment.swift
//  WeWatch
//
//  Created by Anton on 29/11/2024.
//

import Foundation

internal enum Environment {
    
    internal enum Key: String {
        
        case apiKey = "API_KEY"
        case baseUrl = "BASE_URL"
        case apiPin = "API_PIN"
    }
    
    internal static let infoDictionary: [String: Any] = {
        guard let dictionary: [String: Any] = Bundle.main.infoDictionary else {
            fatalError("plist file not found")
        }
        return dictionary
    }()
    
    internal static func getPlistValue(_ key: Key) -> String {
        guard let value = Environment.infoDictionary[key.rawValue] as? String else {
            fatalError("\(key.rawValue) not set in plist")
        }
        return value
    }
}
