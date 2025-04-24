//
//  MovieResponse.swift
//  WeWatch
//
//  Created by Anton on 18/02/2025.
//

import Foundation

internal struct MovieResponse: Codable {
    
    internal let data: Array<DataForMovieResponse>?
    internal let status: String?
    internal let links: Links?
}

internal struct DataForMovieResponse: Codable {
    
    internal let aliases: Array<Aliases>?
    internal let id: Int?
    internal let image: String?
    internal let lastUpdated: String?
    internal let name: String?
    internal let nameTranslations: Array<String>?
    internal let overviewTranslations: Array<String>?
    internal let score: Int?
    internal let slug: String?
    internal let status: Status?
    internal let runtime: Int?
    internal let year: String?
}

internal struct Aliases: Codable {
    
    internal let language: String?
    internal let name: String?
}

internal struct Status: Codable {
    
    internal let id: Int?
    internal let keepUpdated: Bool?
    internal let name: String?
    internal let recordType: String?
}

internal struct Links: Codable {
    
    internal let prev: String?
    internal let selfLink: String
    internal let next: String?
    internal let totalItems: Int
    internal let pageSize: Int
    
    private enum CodingKeys: String, CodingKey {
        case prev, next, totalItems = "total_items", pageSize = "page_size", selfLink = "self"
    }
}
