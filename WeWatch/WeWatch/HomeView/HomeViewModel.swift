//
//  HomeViewModel.swift
//  WeWatch
//
//  Created by Anton on 21/01/2025.
//

import Foundation

internal final class HomeViewModel: ObservableObject {
    
    private let dbManager: DatabaseManager = .shared
    @Published internal var dataForTodaysSelectionSectionView: Array<Movie> = []
    @Published internal var dataForDiscoveryPreviewModel: Array<MovieCardPreviewModel> = []
    private var errorMessage: String?
    
    fileprivate enum HomeViewModelError: Error {
        case invalidUnwrapping
        case invalidDataFromEndpoint
        case tokenDecodingError
        case insufficientData
    }
    
    internal func prepareDataTodaySelection(query: String) async throws -> Array<Movie> {
        let tokenData: Data = try KeychainManager.getData(key: KeychainManager.KeychainKey.token)
        let token: String = .init(decoding: tokenData, as: UTF8.self)
        let searchResource: Resource<SearchResponse> = .init(
            url: URL.SearchResponseURL,
            method: .get([.init(name: "query", value: "\(query)")]),
            token: token
        )
        var response: SearchResponse = try await Webservice().call(searchResource)
        var attempts: Int = 0
        let maxAttempts: Int = 5
        while (response.data?.count ?? 0) < 10  && attempts < maxAttempts {
            response = try await Webservice().call(searchResource)
            attempts += 1
        }
        if (response.data?.count ?? 0) < 10 {
            throw HomeViewModelError.insufficientData
        }
        let moviesForUI: Array<Movie> = response.data?
            .prefix(10)
            .compactMap { details in
                guard let movieId = details.id,
                      let title = details.name,
                      let overview = details.overview,
                      let releaseDate = details.year,
                      let posterUrl = details.imageUrl else {
                    return nil
                }
                return .init(
                    movieId: movieId,
                    title: title,
                    overview: overview,
                    releaseDate: releaseDate,
                    rating: 3,
                    posterUrl: posterUrl
                )
            } ?? .init()
        for movie in moviesForUI {
            try dbManager.insertMovie(
                movieId: movie.movieId,
                title: movie.title,
                overview: movie.overview,
                releaseDate: movie.releaseDate,
                rating: movie.rating,
                posterUrl: movie.posterUrl
            )
        }
        return moviesForUI
    }
    
    internal func dateFromEndpoint() async throws {
        let todaySelectionData: [Movie] = try await prepareDataTodaySelection(query: randomData())
        await MainActor.run { [weak self] in
            self?.dataForTodaysSelectionSectionView = todaySelectionData
        }
    }
    
    internal func dateFromDatabase() async throws {
        try await MainActor.run { [weak self] in
            self?.dataForTodaysSelectionSectionView = try dbManager.getAllMovies()
        }
    }
    
    internal func hasDateChanged() -> Bool {
        let currentDateString: String = DateFormatter.localizedString(
            from: Date(),
            dateStyle: .short,
            timeStyle: .none
        )
        let lastDate: String? = UserDefaults.standard.string(forKey: "cachedDateString")
        guard lastDate != currentDateString else { return false }
        UserDefaults.standard.setValue(currentDateString, forKey: "cachedDateString")
        return true
    }
    
    internal func dataForTodaySelection() async {
        do {
            if hasDateChanged() {
                try await dateFromEndpoint()
            } else {
                try await dateFromDatabase()
            }
        } catch {
            print(error)
#warning("Handle error later")
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
