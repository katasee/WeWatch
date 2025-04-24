 //
//  SearchResponse.swift
//  WeWatch
//
//  Created by Anton on 01/02/2025.
//

import Foundation

internal struct SearchResponse: Codable {
    
    internal let status: String?
    internal let data: Array<Details>?
}

internal struct Details: Codable {
    
    internal let objectID: String?
    internal let aliases: Array<String>?
    internal let country: String?
    internal let director: String?
    internal let extendedTitle: String?
    internal let genres: Array<String>?
    internal let studios: Array<String>?
    internal let id: String?
    internal let imageUrl: String?
    internal let name: String?
    internal let firstAirTime: String?
    internal let overview: String?
    internal let primaryLanguage: String?
    internal let primaryType: String?
    internal let status: String?
    internal let type: String?
    internal let tvdbID: String?
    internal let year: String?
    internal let slug: String?
    internal let overviews: Dictionary<String, String>?
    internal let translations: Dictionary<String, String>?
    internal let remoteIDs: Array<RemoteID>?
    internal let thumbnail: String?
    
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
    
    internal let id: String?
    internal let type: Int?
    internal let sourceName: String?
}
