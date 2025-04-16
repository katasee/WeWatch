//
//  BaseUrl.swift
//  WeWatch
//
//  Created by Anton on 16/04/2025.
//

import Foundation

extension URL {
    
    static var loginURL: URL {
        return URL(string: "https://api4.thetvdb.com/v4/login")!
    }
    
    static var SearchResponseURL: URL {
        return URL(string: "https://api4.thetvdb.com/v4/search")!
    }
    
    static var GenreResponseURL: URL {
        return URL(string: "https://api4.thetvdb.com/v4/genres")!
    }
}
