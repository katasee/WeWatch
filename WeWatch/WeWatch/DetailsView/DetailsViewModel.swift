//
//  DetailsViewModel.swift
//  WeWatch
//
//  Created by Anton on 28/01/2025.
//

import Foundation

internal final class DetailsViewModel: ObservableObject {
    
    @Published internal var movieForDetailsView: Movie?
    @Published internal var isLoading: Bool = false
    @Published var error: (any Error)?
    private var movieId: String
    internal var bookmarkedMovieIds: Set<String> = .init()
    internal let dbManager: DatabaseManager
    
    internal init(
        movieId: String,
        dbManager: DatabaseManager = .shared
    ) {
        self.movieId = movieId
        self.dbManager = dbManager
    }
    
    internal func fetchData() async {
        await MainActor.run { [weak self] in
            self?.isLoading = true
        }
        await dataFromEndpoint()
        await MainActor.run { [weak self] in
            self?.isLoading = false
        }
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
            await updateBookmarks()
            guard var detailsData: Movie = try await prepareDetailsFromEndpoint(id: movieId).first else {
                return
            }
            detailsData.isBookmarked = bookmarkedMovieIds.contains(detailsData.id)
            let filtredMovie: Movie = detailsData
            try await MainActor.run { [weak self] in
                self?.movieForDetailsView = detailsData
            }
        } catch {
            await dateFromDatabase()
        }
    }
    
    private func dateFromDatabase() async {
        do {
            var detailsData: Movie = try await dbManager.fetchMovie(by: movieId)
            detailsData.isBookmarked = bookmarkedMovieIds.contains(detailsData.id)
            let filtredMovie: Movie = detailsData
            await MainActor.run { [weak self] in
                self?.movieForDetailsView = detailsData
            }
        } catch {
            await MainActor.run { [weak self] in
                self?.error = error
            }
        }
    }
    
    internal func updateBookmarks() async {
        do {
            let bookmarked = try await dbManager.fetchMovieByList(forList: Constans.bookmarkList)
            let ids = Set(bookmarked.map { $0.id })
            await MainActor.run { [weak self] in
                self?.bookmarkedMovieIds = ids
            }
        } catch {
            await MainActor.run { [weak self] in
                self?.error = error
            }
        }
    }
    
    internal func refreshBookmarked(
        active: Bool,
        movieId: String,
        selectedMovie: Movie
    ) {
        Task { [weak self] in
            do {
                if active {
                    try await dbManager.insert(selectedMovie)
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
                await MainActor.run { [weak self] in
                    movieForDetailsView = movieForDetailsView.map { movie in
                        var updatedMovie = movie
                        if movie.id == movieId {
                            updatedMovie.isBookmarked = active
                        }
                        return updatedMovie
                    }
                }
            } catch {
                await MainActor.run { [weak self] in
                    self?.error = error
                }
            }
            await updateBookmarks()
        }
    }
}
