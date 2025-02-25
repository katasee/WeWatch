//
//  DiscoveryViewModel.swift
//  WeWatch
//
//  Created by Anton on 17/02/2025.
//

import Foundation

internal final class DiscoveryViewModel: ObservableObject {
    
    @Published internal var dataForAllMovieTab: Array<MovieForDiscoveryView> = []
    @Published internal var dataForFilteredMovies: Array<Movie> = []
    @Published internal var genresForDiscoveryView: Array<Genre> = []
    @Published internal var selectedGenre: Genre = .init(title: "All")
    internal var isFirstTimeLoad = true
    internal var page: String = "0"
    internal var currentPage: Int = 0
    internal var isBackEndDateEmpty: Bool = false
    internal var isFirstTimeDatabaseLoad: Bool = true
    internal var createTable: Bool = UserDefaults.standard.bool(forKey: "table")
    
    internal func withDb() async {
        do {
            if createTable == false {
                currentPage += 1
                movieFromEndpoint()
                createTable = true
                UserDefaults.standard.set(createTable, forKey: "table")
            } else {
                if isFirstTimeDatabaseLoad == true {
                    try await dataFromDatabase()
                    isFirstTimeDatabaseLoad = false
                }
                Task {
                    let discoveryMovieData: [MovieForDiscoveryView] = try await prepareDataDiscoveryView(page: String(currentPage))
                    let filterMovie: [Movie] = try await prepareDataForDiscoverySelection(genre: filterGenres(), page: String(currentPage))
                    currentPage += 1
                    if discoveryMovieData.isEmpty {
                        isBackEndDateEmpty = true
                    } else {
                        isBackEndDateEmpty = false
                        await MainActor.run { [weak self] in
                            self?.dataForAllMovieTab.append(contentsOf: discoveryMovieData)
                            self?.dataForFilteredMovies.append(contentsOf: filterMovie)
                        }
                    }
                }
            }
        } catch {
            print(error)
        }
    }
    
    internal func movieFromEndpoint() -> Bool {
        if isFirstTimeLoad == false {
            Task {
                do {
                    let discoveryMovieData: [MovieForDiscoveryView] = try await prepareDataDiscoveryView(page: String(currentPage))
                    let filterMovie: [Movie] = try await prepareDataForDiscoverySelection(genre: filterGenres(), page: String(currentPage))
                    currentPage += 1
                    if discoveryMovieData.isEmpty {
                        isBackEndDateEmpty = true
                    } else {
                        isBackEndDateEmpty = false
                        await MainActor.run { [weak self] in
                            self?.dataForAllMovieTab.append(contentsOf:  discoveryMovieData)
                            self?.dataForFilteredMovies.append(contentsOf:  filterMovie)
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
    
    internal func prepareDataDiscoveryView(page: String) async throws -> Array<MovieForDiscoveryView> {
        let tokenData: Data = try KeychainManager.getData(key: KeychainManager.KeychainKey.token)
        let token: String = .init(decoding: tokenData, as: UTF8.self)
        let listsResource: Resource<MovieResponse> = .init(
            url: URL.MoviesResponseURL,
            method: .get([.init(name: "page", value: page)]),
            token: token
        )
        let response: MovieResponse = try await Webservice().call(listsResource)
        let moviesForUI: Array<MovieForDiscoveryView> = response.data?
            .compactMap { MovieDetails in
                guard let movieId = MovieDetails.id,
                      let title = MovieDetails.name,
                      let image = MovieDetails.image else {
                    return nil
                }
                return .init(
                    id: movieId,
                    title: title,
                    rating: 3,
                    image: image
                )
            } ?? .init()
        print(isFirstTimeDatabaseLoad)
        if isFirstTimeDatabaseLoad == true {
            for movie in moviesForUI {
                do {
                    let dbManager = try DatabaseManager(dataBaseName: "myApp.sqlite")
                    try dbManager.createTable(for: TableForDiscoveryView.self)
                    let newMovie = TableForDiscoveryView(
                        id: movie.id,
                        title: movie.title,
                        rating: movie.rating,
                        posterUrl: movie.image
                    )
                    try dbManager.insert(newMovie)
                }
            }
        }
        return moviesForUI
    }
    
    internal func prepareGenreForDiscoveryView() async throws -> Array<Genre> {
        let tokenData: Data = try KeychainManager.getData(key: KeychainManager.KeychainKey.token)
        let token: String = .init(decoding: tokenData, as: UTF8.self)
        let listsResource: Resource<MovieResponse> = .init(
            url: URL.GenreResponseURL,
            method: .get([.init(name: "", value: "")]),
            token: token
        )
        let response: MovieResponse = try await Webservice().call(listsResource)
        var genreForUI: Array<Genre> = response.data?
            .compactMap { Genre in
                guard let genre = Genre.name else {
                    return nil
                }
                return .init(title: genre)
            } ?? .init()
        genreForUI.insert(Genre(title: "All"), at: 0)
        return genreForUI
    }
    
    internal func prepareDataForDiscoverySelection(genre: String, page: String) async throws -> Array<Movie> {
        let tokenData: Data = try KeychainManager.getData(key: KeychainManager.KeychainKey.token)
        let token: String = .init(decoding: tokenData, as: UTF8.self)
        let searchResource: Resource<SearchResponse> = .init(
            url: URL.SearchResponseURL,
            method: .get([
                .init(name: "query", value: genre),
                .init(name: "limit", value: "100"),
                .init(name: "page", value: page)
            ]),
            token: token
        )
        var response: SearchResponse = try await Webservice().call(searchResource)
        let moviesForUI: Array<Movie> = response.data?
            .compactMap { details in
                guard let movieId = details.id,
                      let title = details.name,
                      let overview = details.overview,
                      let releaseDate = details.year,
                      let posterUrl = details.imageUrl
                else {
                    return nil
                }
                return .init(
                    movieId: movieId,
                    title: title,
                    overview: overview,
                    releaseDate: releaseDate,
                    rating: 3,
                    posterUrl: posterUrl
                //                    genres: genres
                )
            } ?? .init()
        //        for movie in moviesForUI {
        //            try dbManager.insertMovie(
        //                movieId: movie.movieId,
        //                title: movie.title,
        //                overview: movie.overview,
        //                releaseDate: movie.releaseDate,
        //                rating: movie.rating,
        //                posterUrl: movie.posterUrl
        //            )
        //        }
        return moviesForUI
    }
    
    internal func genreFromEndpoint() async throws {
        let genre: [Genre] = try await prepareGenreForDiscoveryView()
        await MainActor.run { [weak self] in
            self?.genresForDiscoveryView = genre
            if let firstGenre = genre.first {
                selectedGenre = firstGenre
            }
        }
    }
    
    internal func dataFromDatabase() async throws {
        try await MainActor.run { [weak self] in
            self?.dataForAllMovieTab = try DatabaseManager().fetch(TableForDiscoveryView.self).compactMap { movie in
                MovieForDiscoveryView (
                    id: movie.id,
                    title: movie.title,
                    rating: movie.rating,
                    image: movie.posterUrl
                )
            }
        }
    }
    
    internal func dateFromSearchEndpoint() async throws {
        let todaySelectionData: [Movie] = try await prepareDataForDiscoverySelection(genre: filterGenres(), page: String(currentPage))
        await MainActor.run { [weak self] in
            self?.dataForFilteredMovies = todaySelectionData
        }
    }
    
    internal func prepeareGenreForDiscoveryView() async {
        do {
            try await genreFromEndpoint()
        } catch {
            print(error)
        }
    }
    
    internal func prepeareDataForFilteredMovies() async {
        do {
            try await dateFromSearchEndpoint()
        } catch {
            print(error)
        }
    }
    
    internal func filterGenres() -> String {
        let chooseGenre = selectedGenre.title
        return chooseGenre
    }
}





