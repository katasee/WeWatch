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
    internal var dbManager: DatabaseManager = .init(dataBaseName: DatabaseConfig.name)
    internal var bookmarkedMovieIds: Set<String> = .init()
    
    init(dbManager: DatabaseManager) {
        self.dbManager = dbManager
    }
    
    func idFromDatabase() async throws {
        let movieIds = try await dbManager.fetchMovieByList(forList: Constans.bookmarkList).map { $0.id }
         await MainActor.run { [weak self] in
            self?.bookmarkedMovieIds = Set(movieIds)
        }
    }
    
    internal func dataFromDatabase() async {
        do {
            try await idFromDatabase()
            let fetchMovie = try await dbManager.fetchMovieByList(forList: Constans.bookmarkList)
            let filtredMovie = fetchMovie.map { movie in
                 var mutableMovie = movie
                 mutableMovie.isBookmarked = bookmarkedMovieIds.contains(movie.id)
                print(bookmarkedMovieIds)
                     return mutableMovie
             }
                    await MainActor.run { [weak self] in
                        self?.dataForBookmarkView = filtredMovie
                    }
        } catch {
            print(error)
        }
    }
    
    internal func removeFromDatabase(movieId: String) async {
        do {
            try await dbManager.delete(from: Movie.self, id: movieId)
            await MainActor.run { [weak self] in
                self?.dataForBookmarkView.removeAll { $0.id == movieId }
            }
        } catch {
            print(error)
        }
    }
    internal func removeAllMovie() async {
        do {
            try await dbManager.deleteAll(from: Movie.self)
            let updateData = try await dbManager.fetchMovieByList(forList: Constans.bookmarkList)
            let filtredMovie = updateData.map { movie in
                 var mutableMovie = movie
                 mutableMovie.isBookmarked = bookmarkedMovieIds.contains(movie.id)
                print(bookmarkedMovieIds)
                     return mutableMovie
             }
            await MainActor.run { [weak self] in
                self?.dataForBookmarkView = updateData
            }
        } catch {
            
        }
    }
    
    internal func refreshBookmarked(active: Bool, movieId: String) async {
            if active {
                bookmarkedMovieIds.insert(movieId)
            } else {
                bookmarkedMovieIds.remove(movieId)
            }
        await MainActor.run {
            dataForBookmarkView = dataForBookmarkView.map { movie in
                var updatedMovie = movie
                if movie.id == movieId {
                    updatedMovie.isBookmarked = active
                }
                return updatedMovie
            }
        }
    }
    
    internal var filteredBookmarkedMovie: Array<Movie> {
        if searchText.isEmpty {
            dataForBookmarkView
        } else {
            dataForBookmarkView.filter {
                $0.title.localizedStandardContains(searchText) ||
                $0.genres.localizedStandardContains(searchText) ||
                $0.overview.localizedStandardContains(searchText) 
            }
        }
    }
}

