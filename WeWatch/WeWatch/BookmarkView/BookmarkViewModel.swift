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
    
    init(dbManager: DatabaseManager) {
        self.dbManager = dbManager
    }
    
    internal func dataFromDatabase() async {
        do {
            let fetchMovie = try await dbManager.fetchMovieByList(forList: Constans.bookmarkList)
                    await MainActor.run { [weak self] in
                        self?.dataForBookmarkView = fetchMovie
                    }
        } catch {
            print(error)
        }
    }
    
    internal func removeFromDatabase(movieId: String) async {
        do {
            try await dbManager.delete(from: Movie.self, id: movieId)
        } catch {
            print(error)
        }
    }
    
    internal func removeAllMovie() async {
        do {
            try await dbManager.deleteAll(from: Movie.self)
        } catch {
            
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

