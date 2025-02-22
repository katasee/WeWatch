//
//  DiscoveryViewModel.swift
//  WeWatch
//
//  Created by Anton on 17/02/2025.
//

import Foundation

internal final class DiscoveryViewModel: ObservableObject {
    
    //    private let dbManager: DatabaseManagerForDiscoveryView = .shared
    @Published internal var dataForAllMovieTab: Array<MovieForDiscoveryView> = []
    @Published internal var dataForFilteredMovies: Array<Movie> = []
    @Published internal var genresForDiscoveryView: Array<Genre> = []
    @Published internal var selectedGenre: Genre = .init(title: "All")
    internal var isFirstTimeLoad = true
    internal var filterMovieIsFirstTimeLoad = true
    internal var page: String = "0"
    internal var currentPage: Int = 0
    internal var currentPageForFilterMovie: Int = 0
    internal var isBackEndDateEmpty: Bool = false
    
    
    internal func hasReachedEnd() -> Bool {
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
        //        for movie in moviesForUI {
        //            try dbManager.insertMovie(
        //                movieId: String(movie.id), title: movie.title, rating: movie.rating, posterUrl: movie.image
        //            )
        //        }
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
                      let posterUrl = details.imageUrl,
                      let genres = details.genres else {
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
    
    internal func dateFromSearchEndpoint() async throws {
        let todaySelectionData: [Movie] = try await prepareDataForDiscoverySelection(genre: filterGenres(), page: String(currentPage))
        await MainActor.run { [weak self] in
            self?.dataForFilteredMovies = todaySelectionData
        }
    }
    
    //    internal func dateFromEndpoint() async throws {
    //        let discoveryMovieData: [MovieForDiscoveryView] = try await prepareDataDiscoveryView(page: String(currentPage))
    //        await MainActor.run { [weak self] in
    //            self?.dataForAllMovieTab = discoveryMovieData
    //        }
    //    }
    
    //    internal func prepeareDataForAllMovies() async {
    //        do {
    //            try await dateFromEndpoint()
    //        } catch {
    //            print(error)
    //        }
    //    }
    
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
        }
    }
    
    internal func filterGenres() -> String {
        let chooseGenre = selectedGenre.title
        return chooseGenre
    }
}





