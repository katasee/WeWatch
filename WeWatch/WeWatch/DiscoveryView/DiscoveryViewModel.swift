//
//  DiscoveryViewModel.swift
//  WeWatch
//
//  Created by Anton on 17/02/2025.
//

import Foundation

internal final class DiscoveryViewModel: ObservableObject {
    
    @Published internal var dataForAllMovieTab: Array<Movie> = []
    @Published internal var genresForDiscoveryView: Array<Genre> = .init()
    @Published internal var selectedGenre: Genre = .init(id: "0", title: "All")
    @Published internal var isFetchingNextPage = false
    @Published internal var isLoading: Bool = false
    @Published var error: (any Error)?
    internal var fetchDataError: Bool = false
    internal var appendDataError: Bool = false
    internal var bookmarkedMovieIds: Set<String> = .init()
    internal var currentPage: Int = 0
    internal var isBackEndDateEmpty: Bool = false
    internal let dbManager: DatabaseManager
    
    internal init(dbManager: DatabaseManager = .shared) {
        self.dbManager = dbManager
    }
    
    internal func fetchData() async {
        await MainActor.run { [weak self] in
            self?.isLoading = true
        }
        await dataForDiscoveryView()
    }
    
    internal func dataForDiscoveryView() async {
        do {
            await updateBookmarksIds()
            await MainActor.run { [weak self] in
                self?.dataForAllMovieTab = .init()
                self?.currentPage = 0
            }
            let discoveryMovieData: Array<Movie> = try await prepareDataForDiscoveryView(
                genre: filterGenres(),
                page: String(currentPage)
            )
            let filtredMovie: [Movie] = discoveryMovieData.updateBookmarkedStatus(bookmarkedMovieIds: bookmarkedMovieIds)
            await MainActor.run { [weak self] in
                self?.dataForAllMovieTab = filtredMovie
            }
        } catch {
            await movieDataFromDatabase()
        }
        await MainActor.run { [weak self] in
            self?.isLoading = false
        }
    }
    
    internal func movieDataFromDatabase() async {
        do {
            let moviesFromDb: Array<Movie> = try await dbManager.fetchMovieByGenres(
                forGenre: filterGenres()
            )
            let filtredMovie: [Movie] = moviesFromDb.updateBookmarkedStatus(bookmarkedMovieIds: bookmarkedMovieIds)
            await MainActor.run { [weak self] in
                self?.dataForAllMovieTab = filtredMovie
            }
        } catch {
            fetchDataError = true
            await MainActor.run { [weak self] in
                self?.error = error
            }
        }
    }
    
    internal func prepareDataForDiscoveryView(
        genre: String,
        page: String
    ) async throws -> Array<Movie> {
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
                      let year: String = details.year,
                      let posterUrl: String = details.imageUrl,
                      let genres = details.genres?.joined(separator: ", ")
                else {
                    return nil
                }
                return .init(
                    id: movieId,
                    title: title,
                    overview: overview,
                    year: year,
                    posterUrl: posterUrl,
                    country: "",
                    genres: genres
                )
            } ?? .init()
        if currentPage < 2 {
            for movie in moviesForUI {
                try await dbManager.insert(movie)
                try await dbManager.insertMovieGenre(
                    movieId: movie.id,
                    genreId: genre
                )
            }
        }
        return moviesForUI
    }
    
    internal func fetchNextPage() {
        if isFetchingNextPage {
            return
        }
        Task { [weak self] in
            await MainActor.run { [weak self] in
                self?.isFetchingNextPage = true
            }
            do {
                currentPage += 1
                let discoveryMovieData: [Movie] = try await prepareDataForDiscoveryView(
                    genre: selectedGenre.title,
                    page: String(currentPage)
                )
                
                await MainActor.run { [weak self] in
                    self?.dataForAllMovieTab.append(contentsOf: discoveryMovieData)
                    self?.isFetchingNextPage = false
                    
                }
            } catch {
                appendDataError = true
                await MainActor.run { [weak self] in
                    self?.error = error
                    self?.isFetchingNextPage = false
                }
            }
        }
    }
    
    internal func updateBookmarksIds() async {
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
                    dataForAllMovieTab = dataForAllMovieTab.map { movie in
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
            await updateBookmarksIds()
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
                try await dbManager.insert(genre)
                try await dbManager.attachListOfGenre(
                    genreId: genre.id,
                    name: genre.title
                )
            } catch {
                await MainActor.run { [weak self] in
                    self?.error = error
                }
            }
        }
        return genreForUI
    }
    
    internal func dataFromEndpointForGenreTabs() async {
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
            await MainActor.run { [weak self] in
                self?.error = error
            }
        }
    }
    
    internal func filterGenres() -> String {
        let chooseGenre: String = selectedGenre.title
        return chooseGenre
    }
}
