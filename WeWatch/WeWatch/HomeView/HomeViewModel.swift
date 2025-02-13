//
//  HomeViewModel.swift
//  WeWatch
//
//  Created by Anton on 21/01/2025.
//

import Foundation

internal final class HomeViewModel: ObservableObject {
    internal let dbManager: DatabaseManager = .shared
    @Published internal var dataForTodaysSelectionSectionView: Array<Movie> = []
    @Published internal var dataForDiscoveryPreviewModel: Array<MovieCardPreviewModel> = []
    private var errorMessage: String?

    internal enum KeychainKey {
        static let token: String = "token"
    }
    
    fileprivate enum vieModelError: Error {
        case invalidUnwrapping
        case invalidDataFromEndpoint
    }

    internal func prepareDataTodaySelection(query: String) async throws -> [Movie] {
        
        let tokenData: Data? = try KeychainManager.getData(key: KeychainKey.token)
               let token: String = .init(decoding: tokenData ?? Data(), as: UTF8.self)
         let searchResource: Resource<HomeViewEndpoint> = .init(
            url: URL.homeViewEndpointURL,
            method: .get([.init(name: "query", value: "\(query)")]),
            token: token
        )
        do {
            var response: HomeViewEndpoint = try await Webservice().call(searchResource)
            while (response.data?.count ?? 0) < 10 {
                response = try await Webservice().call(searchResource)
            }
            let movieForUI: [Movie]? =  response.data?.prefix(10).compactMap { details in
                if let movieId: String = details.id,
                   let title: String = details.name,
                   let overview: String = details.overview,
                   let releaseDate: String = details.year,
                   let posterUrl: String = details.imageUrl
                {
//                    try dbManager.insertMovie(
//                        movieId: movieId,
//                        title: title,
//                        overview: overview,
//                        releaseDate: releaseDate,
//                        rating: 3,
//                        posterUrl: posterUrl
//                    )

                    return Movie(
                        movieId: movieId,
                        title: title,
                        overview: overview,
                        releaseDate: releaseDate,
                        rating: 3,
                        posterUrl: posterUrl
                    )
                } else {
                    return nil
                }
            }
            guard let todaySelectionData: [Movie] = movieForUI else {
                throw vieModelError.invalidUnwrapping
            }
            await MainActor.run { [weak self] in
                self?.dataForTodaysSelectionSectionView = todaySelectionData
            }
        } catch {
            throw vieModelError.invalidDataFromEndpoint
        }
        return dataForTodaysSelectionSectionView
    }
    
    internal func dateFromEndpoint() async throws {
        do {
            try await prepareDataTodaySelection(query: randomData())
        } catch {
            print(error)
        }
    }
    
    internal func dateFromDatabase() async throws {
        try await MainActor.run { [weak self] in
            self?.dataForTodaysSelectionSectionView = try dbManager.getAllMovies()
        }
    }
    
    internal func hasDateChanged() -> Bool {
        let currentDateString = DateFormatter.localizedString(
            from: Date(),
            dateStyle: .short,
            timeStyle: .none
        )
        let lastDate = UserDefaults.standard.string(forKey: "cachedDateString")
        guard "10/02/2025" != currentDateString else { return false }
        UserDefaults.standard.setValue(currentDateString, forKey: "cachedDateString")
        return true
    }
    
    internal func dateCheck() async throws {
        do {
            if hasDateChanged() {
                try dbManager.deleteMovie()
                try await dateFromEndpoint()
            } else {
                try await dateFromDatabase()
            }
        } catch {
            print(error)
        }
    }
    
    internal func randomData() -> String {
        let alphabet: String = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        return alphabet.randomElement().map(String.init) ?? "A"
    }
    
    internal func prepareDataDiscovery() {
        dataForDiscoveryPreviewModel = MovieCardPreviewModel.mock()
    }
}
