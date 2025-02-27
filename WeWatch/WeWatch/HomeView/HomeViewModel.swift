//
//  HomeViewModel.swift
//  WeWatch
//
//  Created by Anton on 21/01/2025.
//

import Foundation

internal final class HomeViewModel: ObservableObject {
    
    //    private let dbManager: DatabaseManager = .shared
    @Published internal var dataForTodaysSelectionSectionView: Array<Movie> = []
    @Published internal var dataForDiscoverySectionView: Array<Movie> = []
//    internal var currentPage: Int = 0
    internal var isFirstTimeLoad = true
//    internal var isFirstTimeDatabaseLoad: Bool = true


    
    fileprivate enum HomeViewModelError: Error {
        case insufficientData
    }
    
    internal func prepareDataDiscoverySection(query: String) async throws -> Array<Movie> {
        let tokenData: Data = try KeychainManager.getData(key: KeychainManager.KeychainKey.token)
        let token: String = .init(decoding: tokenData, as: UTF8.self)
        let listsResource: Resource<SearchResponse> = .init(
            url: URL.SearchResponseURL,
            method: .get([.init(name: "query", value: "\(query)")]),
            token: token
        )
        let response: SearchResponse = try await Webservice().call(listsResource)
        let moviesForUI: Array<Movie> = response.data?
            .compactMap { MovieDetails in
                guard let movieId = MovieDetails.id,
                      let title = MovieDetails.name,
                      let overview = MovieDetails.overview,
                      let releaseDate = MovieDetails.year,
                      let posterUrl = MovieDetails.imageUrl,
                      let genres = MovieDetails.genres else {
                    return nil
                }
                return .init(
                    movieId: movieId,
                    title: title,
                    overview: overview,
                    releaseDate: releaseDate,
                    rating: 3,
                    posterUrl: posterUrl,
                    genres: genres
                )
            } ?? .init()
//        print(isFirstTimeDatabaseLoad)
//        if isFirstTimeDatabaseLoad == true {
//            for movie in moviesForUI {
//                do {
//                    let dbManager = try DatabaseManager(dataBaseName: "myApp.sqlite")
//                    try dbManager.createTable(for: TableForDiscoveryView.self)
//                    let newMovie = TableForDiscoveryView(
//                        id: movie.id,
//                        title: movie.title,
//                        rating: movie.rating,
//                        posterUrl: movie.image
//                    )
//                    try dbManager.insert(newMovie)
//                }
//            }
//        }
        return moviesForUI
    }
    
    internal func dateFromEndpointForDiscoverySection() async throws {
        let discoveryMovieData: [Movie] = try await prepareDataDiscoverySection(query: randomData())
            await MainActor.run { [weak self] in
                self?.dataForDiscoverySectionView = discoveryMovieData
            }
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
                      let posterUrl = details.imageUrl,
                      let genres = details.genres
                else {
                    return nil
                }
                return .init(
                    movieId: movieId,
                    title: title,
                    overview: overview,
                    releaseDate: releaseDate,
                    rating: 3,
                    posterUrl: posterUrl,
                    genres: genres
                )
            } ?? .init()
//        for movie in moviesForUI {
//            do {
//                let dbManager = try DatabaseManager(dataBaseName: "myApp.sqlite")
//                try dbManager.createTable(for: TableForHomeView.self)
//                let newMovie = TableForHomeView(id: movie.id, title: movie.title, overview: movie.overview, releaseDate: movie.releaseDate, rating: movie.rating, posterUrl: movie.posterUrl, genres: movie.genres)
//                try dbManager.insert(newMovie)
//            }
//        }
        return moviesForUI
    }
    
    internal func dateFromEndpoint() async throws {
        let todaySelectionData: [Movie] = try await prepareDataTodaySelection(query: randomData())
        await MainActor.run { [weak self] in
            self?.dataForTodaysSelectionSectionView = todaySelectionData
        }
    }
    
//    internal func dateFromDatabase() async throws {
//        try await MainActor.run { [weak self] in
//            self?.dataForTodaysSelectionSectionView = try DatabaseManager().fetch(TableForHomeView.self).compactMap { movie in
//                guard let movieId = movie.id else { return nil}
//                return Movie(
//                    movieId: movieId,
//                    title: movie.title,
//                    overview: movie.overview,
//                    releaseDate: movie.releaseDate,
//                    rating: movie.rating,
//                    posterUrl: movie.posterUrl,
//                    genres: movie.genres
//                )}
//        }
//    }
    
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
//            if hasDateChanged() {
                try await dateFromEndpoint()
//            } else {
//                try await dateFromDatabase()
//            }
        } catch {
            print(error)
#warning("Handle error later")
        }
    }
    
    internal func randomData() -> String {
        let alphabet: String = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        return alphabet.randomElement().map(String.init) ?? "A"
    }
}
