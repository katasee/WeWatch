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
    
    func refreshBookmarkedIDs() async throws {
        let movieIds = try await dbManager.fetchMovieByList(forList: Constans.bookmarkList).map { $0.id }
         await MainActor.run { [weak self] in
            self?.bookmarkedMovieIds = Set(movieIds)
        }
    }
    
    internal func loadBookmarkData() async {
        do {
            try await refreshBookmarkedIDs()
            let fetchMovie = try await dbManager.fetchMovieByList(forList: Constans.bookmarkList)
            print(fetchMovie.count)
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
    
    internal func refreshBookmarked(active: Bool, movieId: String) async {
        do {
            try await dbManager.detachMovieFromList(listId: Constans.bookmarkList, movieId: movieId)
            await MainActor.run { [weak self] in
                self?.bookmarkedMovieIds.remove(movieId)
                print(bookmarkedMovieIds)
            }
            await loadBookmarkData()
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
            print(error)
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

