//
//  UpdateBookmarkExtension.swift
//  WeWatch
//
//  Created by Anton on 29/03/2025.
//

import Foundation

extension Array<Movie> {
    
    func updateBookmarkedStatus(bookmarkedMovieIds: Set<String>) -> [Movie] {
        map { movie -> Movie in
            var updateMovie = movie
            updateMovie.isBookmarked = bookmarkedMovieIds.contains(movie.id)
            return updateMovie
        }
    }
}
