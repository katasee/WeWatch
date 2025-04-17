//
//  Resource.swift
//  WeWatch
//
//  Created by Anton on 16/04/2025.
//

import Foundation

internal struct Resource<T: Codable> {
    
    internal let url: URL
    internal var method: HttpMethod = .get([])
    internal let token: String?
}
