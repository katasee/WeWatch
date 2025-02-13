//
//  HomeViewEndpoint.swift
//  WeWatch
//
//  Created by Anton on 01/02/2025.
//

import Foundation

internal struct HomeViewEndpoint: Codable {
    
    var status: String?
    var data: [Details]?
}

internal struct Details: Codable {
    
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
    
    internal enum CodingKeys: String, CodingKey {
        case objectID = "objectID"
        case aliases = "aliases"
        case country = "country"
        case director = "director"
        case extendedTitle = "extended_title"
        case genres = "genres"
        case studios = "studios"
        case id = "id"
        case imageUrl = "image_url"
        case name = "name"
        case firstAirTime = "first_air_time"
        case overview = "overview"
        case primaryLanguage = "primary_language"
        case primaryType = "primary_type"
        case status = "status"
        case type = "type"
        case tvdbID = "tvdb_id"
        case year = "year"
        case slug = "slug"
        case overviews = "overviews"
        case translations = "translations"
        case remoteIDs = "remote_ids"
        case thumbnail = "thumbnail"
    }
}

internal struct RemoteID: Codable {
    
    var id: String?
    var type: Int?
    var sourceName: String?
}
