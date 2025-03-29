//
//  BookmarkViewModel.swift
//  WeWatch
//
//  Created by Anton on 27/01/2025.
//

import Foundation

internal final class BookmarkViewModel: ObservableObject {
    
    @Published internal var searchText: String = ""
    @Published internal var dataForBookmarkView: Array<Movie> = .init()
    internal var bookmarkedMovieIds: Set<String> = .init()
    internal let dbManager: DatabaseManager = .shared
    
    func refreshBookmarkedIDs() async throws {
        let movies = try await dbManager.fetchMovieByList(forList: Constans.bookmarkList)
        let ids = movies.map { $0.id }
         await MainActor.run { [weak self] in
             self?.bookmarkedMovieIds = Set(ids)
        }
    }
    
    internal func loadBookmarkData() async {
        do {
            try await refreshBookmarkedIDs()
            let movies = try await dbManager.fetchMovieByList(forList: Constans.bookmarkList)
            print(movies.count)
            let filtredMovies = movies.map { movie -> Movie in
                 var updatedMovie = movie
                updatedMovie.isBookmarked = bookmarkedMovieIds.contains(movie.id)
                print(bookmarkedMovieIds)
                     return updatedMovie
             }
                    await MainActor.run { [weak self] in
                        self?.dataForBookmarkView = filtredMovies
                    }
        } catch {
      print("Error loading bookmark data: \(error)")
        }
    }
    
    internal func refreshBookmarked(active: Bool, movieId: String) async {
        do {
            try await dbManager.detachMovieFromList(
                listId: Constans.bookmarkList,
                movieId: movieId
            )
            await MainActor.run { [weak self] in
                self?.bookmarkedMovieIds.remove(movieId)
                print(bookmarkedMovieIds)
            }
            await loadBookmarkData()
        } catch {
    print("Error removing bookmark for movie \(movieId): \(error)")
        }
    }
    
    internal func removeAllMovie() async {
        do {
            let movies = try await dbManager.fetchMovieByList(forList: Constans.bookmarkList)
            for movie in movies {
                try await dbManager.detachMovieFromList(
                    listId: Constans.bookmarkList,
                    movieId: movie.id
                )
             }
            await loadBookmarkData()
         } catch {
            print("Error removing all bookmarks: \(error)")
         }
     }
    
    internal var filteredBookmarkedMovie: Array<Movie> {
        if searchText.isEmpty {
      return dataForBookmarkView
        } else {
            return dataForBookmarkView.filter {
                $0.title.localizedStandardContains(searchText) ||
                $0.genres.localizedStandardContains(searchText) ||
                $0.overview.localizedStandardContains(searchText) 
            }
        }
    }
}

