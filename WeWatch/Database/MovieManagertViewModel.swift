//
//  MovieManagertViewModel.swift
//  WeWatch
//
//  Created by Anton on 15/01/2025.
//

import Foundation

internal final class MovieManagertViewModel: ObservableObject {
    
    @Published internal var modelManager: [Movie] = []
    @Published internal var movieId: Int = 0
    private let dbManager: DatabaseManager = .shared
    
    internal func deleteDate(movieId: Int) {
        do {
            try dbManager.deleteMovieById(movieId: movieId)
        } catch {
            print(error)
        }
    }
    
    internal func getAllMovies() {
        do {
            self.modelManager = try dbManager.getAllMovies()
        } catch {
            print(error)
        }
    }
}
