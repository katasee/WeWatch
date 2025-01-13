//
//  AddMovieViewModel.swift
//  WeWatch
//
//  Created by Anton on 08/01/2025.
//

import Foundation

internal final class AddMovieViewModel: ObservableObject {
    
    internal let dbManager = DBManager.shared
    
    internal func saveDate(
        movield: Int,
        title: String,
        overview: String,
        releaseDate: String,
        rating: Int,
        posterUrl: String
    ) {
        do {
            try dbManager.insertMovie(movieId: movield, title: title, overview: overview, releaseDate: releaseDate, rating: rating, posterUrl: posterUrl)
        } catch {
            print("error")
        }
    }
}
