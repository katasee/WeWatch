//
//  GenresResponse.swift
//  WeWatch
//
//  Created by Anton on 18/02/2025.
//

import Foundation

internal struct GenreResponse: Codable {
 
    internal let data: Array<GenreData>?
    internal let status: String?
}

internal struct GenreData: Codable {
    
    internal let id: Int?
    internal let name: String?
    internal let slug: String?
}
