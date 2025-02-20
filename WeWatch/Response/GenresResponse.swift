//
//  GenresResponse.swift
//  WeWatch
//
//  Created by Anton on 18/02/2025.
//

import Foundation

internal struct GenresResponse: Codable {
 
    internal let data: [DataForGenresResponse]?
    internal let status: String?
}

internal struct DataForGenresResponse: Codable {
    
    internal let id: Int?
    internal let name: String?
    internal let slug: String?
}
