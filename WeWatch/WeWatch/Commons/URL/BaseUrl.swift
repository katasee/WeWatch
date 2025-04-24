//
//  BaseUrl.swift
//  WeWatch
//
//  Created by Anton on 16/04/2025.
//

import Foundation

extension URL {
    
    internal static var loginURL: URL {
        return URL(string: "https://api4.thetvdb.com/v4/login")!
    }
    
    internal static var SearchResponseURL: URL {
        return URL(string: "https://api4.thetvdb.com/v4/search")!
    }
    
    internal static var GenreResponseURL: URL {
        return URL(string: "https://api4.thetvdb.com/v4/genres")!
    }
}
