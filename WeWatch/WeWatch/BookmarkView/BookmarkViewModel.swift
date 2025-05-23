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
    @Published internal var isLoading: Bool = false
    @Published var error: (any Error)?
    internal var bookmarkedMovieIds: Set<String> = .init()
    internal let dbManager: DatabaseManager
    
    internal init(dbManager: DatabaseManager = .shared) {
        self.dbManager = dbManager
    }
    
    internal func fetchData() async {
        await MainActor.run { [weak self] in
            self?.isLoading = true
        }
        await loadBookmarkData()
        await MainActor.run { [weak self] in
            self?.isLoading = false
        }
    }
    
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
            let filtredMovie: [Movie] = movies.updateBookmarkedStatus(bookmarkedMovieIds: bookmarkedMovieIds)
            await MainActor.run { [weak self] in
                self?.dataForBookmarkView = filtredMovie
            }
        } catch {
            await MainActor.run { [weak self] in
                self?.error = error
            }
        }
    }
    
    internal func refreshBookmarked(
        active: Bool,
        movieId: String
    ) {
        Task { [weak self] in
            do {
                try await dbManager.detachMovieFromList(
                    listId: Constans.bookmarkList,
                    movieId: movieId
                )
                await MainActor.run { [weak self] in
                    self?.bookmarkedMovieIds.remove(movieId)
                }
                await loadBookmarkData()
            } catch {
                await MainActor.run { [weak self] in
                    self?.error = error
                }
            }
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
            await MainActor.run { [weak self] in
                self?.error = error
            }
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
