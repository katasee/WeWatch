//
//  DetailsViewModel.swift
//  WeWatch
//
//  Created by Anton on 28/01/2025.
//

import Foundation

internal final class DetailsViewModel: ObservableObject {
    
    @Published internal var movieForDetailsView: Movie?
    private let dbManager: DatabaseManager
    private var movieId: String
    
    internal init(
        dbManager: DatabaseManager,
        movieId: String
    ) {
        self.dbManager = dbManager
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
            guard let movie: Movie = try await prepareDetailsFromEndpoint(id: movieId).first else {
                return
            }
            try await MainActor.run { [weak self] in
                self?.movieForDetailsView = movie
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
            let movie: Movie = try await dbManager.fetchMovie(by: movieId)
            await MainActor.run { [weak self] in
                self?.movieForDetailsView = movie
            }
        } catch {
            DatabaseError.fetchError(message: "Error fetch movie by id")
        }
    }
}
