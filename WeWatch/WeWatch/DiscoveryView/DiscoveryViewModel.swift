//
//  DiscoveryViewModel.swift
//  WeWatch
//
//  Created by Anton on 17/02/2025.
//

import Foundation

internal final class DiscoveryViewModel: ObservableObject {
    
    private let dbManager: DatabaseManager
    
    internal init(dbManager: DatabaseManager) {
        self.dbManager = dbManager
    }
    
    @Published internal var dataForAllMovieTab: Array<Movie> = []
    @Published internal var genresForDiscoveryView: Array<Genre> = []
    @Published internal var selectedGenre: Genre = .init(id: "0", title: "All")
    internal var isFirstTimeLoad: Bool = true
    internal var currentPage: Int = 0
    internal var isBackEndDateEmpty: Bool = false
    
    fileprivate enum Constans {
        static let refreshIntervalHours: Int = 24
    }
    
    internal func movieDataFromEndpoint() async {
        do {
            let discoveryMovieData: [Movie] = try await prepareDataForDiscoveryView(
                genre: filterGenres(),
                page: String(currentPage)
            )
            await MainActor.run { [weak self] in
                self?.dataForAllMovieTab = discoveryMovieData
            }
        } catch {
            print(error)
        }
    }
    
    internal func movieDataFromDatabase() async {
        do {
            let moviesFromDb: Array<Movie> = try await dbManager.fetchMovieByGenres(forGenre: filterGenres()).compactMap { movie in
                return .init(
                    id: movie.id,
                    title: movie.title,
                    overview: movie.overview,
                    rating: 3,
                    posterUrl: movie.posterUrl,
                    genres: movie.genres
                )
            }
            await MainActor.run { [weak self] in
                self?.dataForAllMovieTab = moviesFromDb
            }
        } catch {
            print(error)
        }
    }
    
    @MainActor
    internal func movieForDiscoveryView() async {
        await MainActor.run { dataForAllMovieTab = [] }
        currentPage = 0
        UserDefaults.standard.set(Date(), forKey: TimeKey.todayTime)
        do {
            if let date: Date = UserDefaults.standard.object(forKey: TimeKey.todayTime) as? Date {
                if try await dbManager.fetchMovieByGenres(forGenre: filterGenres()).isEmpty {
                    await movieDataFromEndpoint()
                } else {
                    if let diff: Int = Calendar.current.dateComponents([.hour], from: date, to: Date()).hour, diff > Constans.refreshIntervalHours {
                        await  movieDataFromEndpoint()
                    } else {
                        await movieDataFromDatabase()
                    }
                }
            }
        } catch {
            print(error)
        }
    }
    
    internal func prepareDataForDiscoveryView(genre: String, page: String) async throws -> Array<Movie> {
        let tokenData: Data = try KeychainManager.getData(key: KeychainManager.KeychainKey.token)
        let token: String = .init(decoding: tokenData, as: UTF8.self)
        let listsResource: Resource<SearchResponse> = .init(
            url: URL.SearchResponseURL,
            method: .get([
                .init(name: "query", value: genre),
                .init(name: "limit", value: "20"),
                .init(name: "page", value: page)
            ]),
            token: token
        )
        let response: SearchResponse = try await Webservice().call(listsResource)
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
        if try await dbManager.fetchMovieByGenres(forGenre: selectedGenre.id).isEmpty {
            let newMovie: Array<Movie> = response.data?
                .compactMap { movie in
                    guard let id: String = movie.id,
                          let title: String = movie.name,
                          let overview: String = movie.overview,
                          let posterUrl: String = movie.imageUrl,
                          let genres = movie.genres?.joined(separator: ", ")
                    else {
                        return nil
                    }
                    return .init(
                        id: id,
                        title: title,
                        overview: overview,
                        rating: 3,
                        posterUrl: posterUrl,
                        genres: genres
                    )
                } ?? .init()
            if currentPage < 1 {
                for movie in newMovie {
                    try await dbManager.insert(movie)
                    try await dbManager.insertMovieGenre(
                        movieId: movie.id,
                        genreId: genre
                    )
                }
            }
        }
        return moviesForUI
    }
    
    internal func fetchNextPage() -> Bool {
        if isFirstTimeLoad == false {
            Task {
                do {
                    currentPage += 1
                    let discoveryMovieData: [Movie] = try await prepareDataForDiscoveryView(
                        genre: selectedGenre.title,
                        page: String(currentPage)
                    )
                    if discoveryMovieData.isEmpty {
                        isBackEndDateEmpty = true
                    } else {
                        isBackEndDateEmpty = false
                        await MainActor.run { [weak self] in
                            self?.dataForAllMovieTab.append(contentsOf: discoveryMovieData)
                        }
                    }
                } catch {
                    print(error)
                }
            }
            return true
        } else {
            return false
        }
    }
    
    internal func dataFromDatabase() async throws {
        let moviesFromDb: Array<Movie> = try await dbManager.fetchMovieByGenres(forGenre: filterGenres()).compactMap { movie in
            return .init(
                id: movie.id,
                title: movie.title,
                overview: movie.overview,
                rating: 3,
                posterUrl: movie.posterUrl,
                genres: movie.genres
            )
        }
        await MainActor.run { [weak self] in
            self?.dataForAllMovieTab = moviesFromDb
        }
    }
    
    internal func prepareGenreForDiscoveryView() async throws -> Array<Genre> {
        let tokenData: Data = try KeychainManager.getData(key: KeychainManager.KeychainKey.token)
        let token: String = .init(decoding: tokenData, as: UTF8.self)
        let listsResource: Resource<GenreResponse> = .init(
            url: URL.GenreResponseURL,
            method: .get([]),
            token: token
        )
        let response: GenreResponse = try await Webservice().call(listsResource)
        var genreForUI: Array<Genre> = response.data?
            .compactMap { genre in
                guard let genreId = genre.id,
                      let title = genre.name
                else {
                    return nil
                }
                return .init(
                    id: String(genreId),
                    title: title
                )
            } ?? .init()
        genreForUI.insert(Genre(id: "0", title: "All"), at: 0)
        for genre in genreForUI {
            do {
//                let tabGenre = Genre(
//                    id: genre.id,
//                    title: genre.title
//                )
                try await dbManager.insert(genre)
                try await dbManager.attachListOfGenre(
                    genreId: genre.id,
                    name: genre.title
                )
            }
        }
        return genreForUI
    }
    
    internal func dataFromEndpointForGenreTabs() async  {
        do {
            if try await dbManager.fetchGenresTab().isEmpty {
                let genre: [Genre] = try await prepareGenreForDiscoveryView()
                await MainActor.run { [weak self] in
                    self?.genresForDiscoveryView = genre
                }
            } else {
                let genreTabsFromDb = try await dbManager.fetchGenresTab()
                await MainActor.run { [weak self] in
                        self?.genresForDiscoveryView = genreTabsFromDb
                }
            }
        } catch {
            print(error)
        }
    }
    
    internal func filterGenres() -> String {
        let chooseGenre: String = selectedGenre.title
        return chooseGenre
    }
}
