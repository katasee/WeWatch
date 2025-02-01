//
//  DomainModels.swift
//  WeWatch
//
//  Created by Anton on 01/02/2025.
//

import Foundation

struct DomainModels: Codable {
    
    var status: String?
    var data: [Details]?
}

struct Details: Codable {
    
    var objectID: String?
    var aliases: [String]?
    var country: String?
    var director: String?
    var extendedTitle: String?
    var genres: [String]?
    var studios: [String]?
    var id: String?
    var imageUrl: String?
    var name: String?
    var firstAirTime: String?
    var overview: String?
    var primaryLanguage: String?
    var primaryType: String?
    var status: String?
    var type: String?
    var tvdbID: String?
    var year: String?
    var slug: String?
    var overviews: [String: String]?
    var translations: [String: String]?
    var remoteIDs: [RemoteID]?
    var thumbnail: String?
    
    enum CodingKeys: String, CodingKey {
        case extendedTitle = "extended_title"
        case imageUrl = "image_url"
        case firstAirTime = "first_air_time"
        case primaryLanguage = "primary_language"
        case primaryType = "primary_type"
        case tvdbID = "tvdb_id"
        case remoteIDs = "remote_ids"
    }
}

struct RemoteID: Codable {
    
    var id: String?
    var type: Int?
    var sourceName: String?
}
