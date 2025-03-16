//
//  HomeViewModel.swift
//  WeWatch
//
//  Created by Anton on 21/01/2025.
//

import Foundation

internal final class HomeViewModel: ObservableObject {
    
    @Published internal var todaySelection: Array<Movie> = []
    @Published internal var discoverySection: Array<Movie> = []
    internal var currentPage: Int = .init()
    var dbManager: DatabaseManager = .init(dataBaseName: DatabaseConfig.name)
    init(dbManager: DatabaseManager) {
        self.dbManager = dbManager
    }
    
    fileprivate enum Constans {
        internal static let discoveryList: String = "DiscoverySection"
        internal static let todaySelectionList: String = "TodaySelection"
        internal static let refreshIntervalHours: Int = 24
    }
    
    fileprivate enum HomeViewModelError: Error {
        case insufficientData
    }
    
    internal func prepareDataDiscoverySection(page: String) async throws -> Array<Movie> {
        let tokenData: Data = try KeychainManager.getData(key: KeychainManager.KeychainKey.token)
        let token: String = .init(decoding: tokenData, as: UTF8.self)
        let listsResource: Resource<SearchResponse> = .init(
            url: URL.SearchResponseURL,
            method: .get([
                .init(name: "query", value: "All"),
                .init(name: "limit", value: "100"),
                .init(name: "page", value: page)
            ]),
            token: token
        )
        let response: SearchResponse = try await Webservice().call(listsResource)
        currentPage += 1
        let moviesForUI: Array<Movie> = response.data?
            .compactMap { MovieDetails in
                guard let id: String = MovieDetails.id,
                      let title: String = MovieDetails.name,
                      let overview: String = MovieDetails.overview,
                      let posterUrl: String = MovieDetails.imageUrl,
                      let genreses: Array<String> = MovieDetails.genres
                else {
                    return nil
                }
                let genres: String = genreses
                    .joined(separator: ", ")
                return .init(
                    id: id,
                    title: title,
                    overview: overview,
                    rating: 3,
                    posterUrl: posterUrl,
                    genres: genres
                )
            } ?? .init()
        if try await dbManager.fetchMovieByList(forList: Constans.discoveryList).isEmpty {
            for movie in moviesForUI {
                try await dbManager.insert(movie)
                try await dbManager.attachMovieToList(
                    listId: Constans.discoveryList,
                    movieId: movie.id
                )
            }
        }
        return moviesForUI
    }
    
    internal func movieForDiscoveryView() async throws {
        do {
            let discoveryMovieData: [Movie] = try await prepareDataDiscoverySection(page: String(currentPage))
            try await MainActor.run { [weak self] in
                self?.discoverySection = discoveryMovieData
                if discoveryMovieData.isEmpty {
                    throw EndpointResponce.dataFromEndpoint
                }
            }
        } catch {
            let fetchMovie = try await dbManager.fetchMovieByList(forList: Constans.discoveryList)
            await MainActor.run { [weak self] in
                self?.discoverySection = fetchMovie
            }
        }
    }
    
    internal func appendDateFromEndpoint() async throws {
        let discoveryMovieData: [Movie] = try await prepareDataDiscoverySection(page: String(currentPage))
        await MainActor.run { [weak self] in
            self?.discoverySection.append(contentsOf: discoveryMovieData)
        }
    }
    
    internal func prepareDataTodaySelection(query: String) async throws -> Array<Movie> {
        let tokenData: Data = try KeychainManager.getData(key: KeychainManager.KeychainKey.token)
        let token: String = .init(decoding: tokenData, as: UTF8.self)
        let searchResource: Resource<SearchResponse> = .init(
            url: URL.SearchResponseURL,
            method: .get([.init(
                name: "query",
                value: "\(query)")
            ]),
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
                guard let movieId: String = details.id,
                      let title: String = details.name,
                      let image: String = details.imageUrl else {
                    return nil
                }
                return .init(
                    id: movieId,
                    title: title,
                    overview: "",
                    rating: 3,
                    posterUrl: image,
                    genres: ""
                )
            } ?? .init()
        for movie in moviesForUI {
            try await dbManager.insert(movie)
            try await dbManager.attachMovieToList(listId: Constans.todaySelectionList, movieId: movie.id)
        }
        return moviesForUI
    }
    
    internal func dataForTodaySelection() async throws {
        do {
            let todaySelectionData: [Movie] = try await prepareDataTodaySelection(query: randomData())
            await MainActor.run { [weak self] in
                self?.todaySelection = todaySelectionData
            }
            if todaySelectionData.isEmpty {
                throw EndpointResponce.dataFromEndpoint
            }
        } catch {
            let fetchMovie = try await dbManager.fetchMovieByList(forList: Constans.discoveryList)
            await MainActor.run { [weak self] in
                self?.todaySelection = fetchMovie
            }
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
    
    internal func randomData() -> String {
        let alphabet: String = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        return alphabet.randomElement().map(String.init) ?? "A"
    }
}
