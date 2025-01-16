//
//  AddMovieViewModel.swift
//  WeWatch
//
//  Created by Anton on 08/01/2025.
//

import Foundation

internal final class AddMovieViewModel: ObservableObject {
    
    private let dbManager: DatabaseManager = .shared
    @Published internal var movieId: Int = 0
    @Published internal var title: String = ""
    @Published internal var overview: String = ""
    @Published internal var releaseDate: String = ""
    @Published internal var rating: Int = 0
    @Published internal var posterUrl: String = ""
    
    internal func saveDate() {
        do {
            try dbManager.insertMovie(
                movieId: movieId,
                title: title,
                overview: overview,
                releaseDate: releaseDate,
                rating: rating,
                posterUrl: posterUrl
            )
        } catch {
            print(error)
        }
    }
}
