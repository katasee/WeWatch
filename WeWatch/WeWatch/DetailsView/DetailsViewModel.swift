//
//  DetailsViewModel.swift
//  WeWatch
//
//  Created by Anton on 28/01/2025.
//

import Foundation

internal final class DetailsViewModel: ObservableObject {
    
    @Published internal var movieForDetailsView: Movie?
    private let dbManager: DatabaseManager = .shared
    private var movieId: String
    internal var bookmarkedMovieIds: Set<String> = .init()
    
    internal init(
        movieId: String
    ) {
        self.movieId = movieId
    }
    
    internal func prepareDetailsFromEndpoint(id: String) async throws -> Array<Movie> {
        let tokenData: Data = try KeychainManager.getData(key: KeychainManager.KeychainKey.token)
        let token: String = .init(decoding: tokenData, as: UTF8.self)
        let detailResource: Resource<SearchResponse> = .init(
            url: URL.SearchResponseURL,
            method: .get([
                .init(name: "query", value: id),
                .init(name: "limit", value: "1")
            ]),
            token: token
        )
        let response: SearchResponse = try await Webservice().call(detailResource)
        let moviesForUI: Array<Movie> = response.data?
            .compactMap { details in
                guard let movieId: String = details.id,
                      let title: String = details.name,
                      let overview: String = details.overview,
                      let posterUrl: String = details.imageUrl,
                      let genres = details.genres?.joined(separator: ", ")
                else {
                    return nil
                }
                return .init(
                    id: movieId,
                    title: title,
                    overview: overview,
                    rating: 3,
                    posterUrl: posterUrl,
                    genres: genres
                )
            } ?? .init()
        return moviesForUI
    }
    
    internal func dataFromEndpoint() async {
        do {
            try await idFromDatabase()
            guard var detailsData: Movie = try await prepareDetailsFromEndpoint(id: movieId).first else {
                return
            }
            detailsData.isBookmarked = bookmarkedMovieIds.contains(detailsData.id)
               print(bookmarkedMovieIds)
                let filtredMovie = detailsData
            try await MainActor.run {
                self.movieForDetailsView = detailsData
                if movieId.isEmpty {
                    throw EndpointResponce.dataFromEndpoint
                }
            }
        } catch {
            await dateFromDatabase()
        }
    }
    
    private func dateFromDatabase() async {
        do {
            var detailsData: Movie = try await dbManager.fetchMovie(by: movieId)
            detailsData.isBookmarked = bookmarkedMovieIds.contains(detailsData.id)
               print(bookmarkedMovieIds)
                let filtredMovie = detailsData
            await MainActor.run { [weak self] in
                self?.movieForDetailsView = detailsData
            }
        } catch {
            DatabaseError.fetchError(message: "Error fetch movie by id")
        }
    }
    
    internal func updateBookmarks() async {
            do {
                let bookmarked = try await dbManager.fetchMovieByList(forList: Constans.bookmarkList)
                let ids = Set(bookmarked.map { $0.id })
                await MainActor.run {
                    self.bookmarkedMovieIds = ids
                }
            } catch {
                print("Error updating bookmarks: \(error)")
            }
        }
    
    internal func refreshBookmarked(active: Bool, movieId: String) async {
        do {
            if active {
                try await dbManager.attachMovieToList(
                    listId: Constans.bookmarkList,
                    movieId: movieId
                )
            } else {
                try await dbManager.detachMovieFromList(
                    listId: Constans.bookmarkList,
                    movieId: movieId
                )
            }
            print(bookmarkedMovieIds)
            await MainActor.run {
                movieForDetailsView = movieForDetailsView.map { movie in
                    var updatedMovie = movie
                    if movie.id == movieId {
                        updatedMovie.isBookmarked = active
                    }
                    return updatedMovie
                }
            }
        } catch {
  print("Error adding bookmark: \(error)")
        }
        await updateBookmarks()
    }
    
    func idFromDatabase() async throws {
        let movieIds = try await dbManager.fetchMovieByList(forList: Constans.bookmarkList).map { $0.id }
        await MainActor.run {
            self.bookmarkedMovieIds = Set(movieIds)
        }
    }
}
