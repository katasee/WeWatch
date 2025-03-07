//
//  HomeViewModel.swift
//  WeWatch
//
//  Created by Anton on 21/01/2025.
//

import Foundation

internal final class HomeViewModel: ObservableObject {
    
    @Published internal var dataForTodaysSelectionSectionView: Array<Movie> = []
    @Published internal var dataForDiscoverySectionView: Array<Movie> = []
    internal let listId = "DiscoverySection"
    internal let todaySelectionList = "TodaySelection"
    internal var isFirstTimeLoad = true
    internal var currentPage: Int = .init()
    
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
                guard let genreses: [String] = MovieDetails.genres else { return nil }
                guard let id: String = MovieDetails.id,
                      let title: String = MovieDetails.name,
                      let overview: String = MovieDetails.overview,
                      let posterUrl: String = MovieDetails.imageUrl
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
        let dbManager: DatabaseManager = try DatabaseManager(dataBaseName: "myApp.sqlite")
        if try dbManager.fetchMovieByList(forList: listId).isEmpty {
            for movie in moviesForUI {
                try dbManager.insert(movie)
                try dbManager.attachMovieToList(
                    listId: listId,
                    movieId: movie.id
                )
            }
        }
        return moviesForUI
    }
    
    internal func movieForDiscoveryView() async {
        do {
            let dbManager: DatabaseManager = try DatabaseManager(dataBaseName: "myApp.sqlite")
            UserDefaults.standard.set(Date(), forKey: "TodayTime")
            if try dbManager.fetchMovieByList(forList: listId).isEmpty{
                let discoveryMovieData: [Movie] = try await prepareDataDiscoverySection(page: String(currentPage))
                await MainActor.run { [weak self] in
                    self?.dataForDiscoverySectionView = discoveryMovieData
                }
            } else {
                if let date: Date = UserDefaults.standard.object(forKey: "TodayTime") as? Date {
                    if let diff: Int = Calendar.current.dateComponents([.hour], from: date, to: Date()).hour, diff > 24 {
                        let discoveryMovieData: [Movie] = try await prepareDataDiscoverySection(page: String(currentPage))
                        await MainActor.run { [weak self] in
                            self?.dataForDiscoverySectionView = discoveryMovieData
                        }
                    } else {
                        currentPage += 1
                        try await MainActor.run { [weak self] in
                            self?.dataForDiscoverySectionView = try dbManager.fetchMovieByList(forList: listId)
                        }
                    }
                }
            }
        } catch {
            print(error)
        }
    }
    
    internal func appendDateFromEndpoint() async throws {
        do {
            let discoveryMovieData: [Movie] = try await prepareDataDiscoverySection(page: String(currentPage))
            await MainActor.run { [weak self] in
                self?.dataForDiscoverySectionView.append(contentsOf: discoveryMovieData)
            }
        } catch {
            print(error)
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
        let dbManager: DatabaseManager = try DatabaseManager(dataBaseName: "myApp.sqlite")
        for movie in moviesForUI {
            try dbManager.insert(movie)
            try dbManager.attachMovieToList(listId: todaySelectionList, movieId: movie.id)
        }
        return moviesForUI
    }
    
    internal func dataForTodaySelection() async throws {
        do {
            if hasDateChanged() {
                let todaySelectionData: [Movie] = try await prepareDataTodaySelection(query: randomData())
                await MainActor.run { [weak self] in
                    self?.dataForTodaysSelectionSectionView = todaySelectionData
                }
            } else {
                try await MainActor.run { [weak self] in
                    self?.dataForTodaysSelectionSectionView = try DatabaseManager(dataBaseName: "myApp.sqlite").fetchMovieByList(forList: todaySelectionList)
                }
            }
        } catch {
            print(error)
#warning("Handle error later")
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
