//
//  EditMovieViewModel.swift
//  WeWatch
//
//  Created by Anton on 15/01/2025.
//

import Foundation

internal final class EditMovieViewModel: ObservableObject {
    
    private let dbManager: DatabaseManager = .shared
    @Published internal var movieId: Int = 0
    @Published internal var title: String = ""
    @Published internal var overview: String = ""
    @Published internal var releaseDate: String = ""
    @Published internal var rating: Int = 0
    @Published internal var posterUrl: String = ""
    
    internal func updateDate(movieId: Int) {
        do {
            try dbManager.updateMovie(
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
