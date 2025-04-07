//
//  SearchViewModel.swift
//  WeWatch
//
//  Created by Anton on 24/01/2025.
//

import Foundation

internal final class SearchViewModel: ObservableObject {
    
    @Published internal var genresForSearchView: Array<Genre> = .init()
    @Published internal var dataForSearchView: Array<Movie> = .init()
    @Published internal var searchText: String = ""
    @Published internal var selectedGenre: Genre = .init(id: "0", title: "All")
    @Published internal var isFetchingNextPage = false
    @Published internal var isLoading: Bool = false
    @Published var error: (any Error)?
    internal var fetchDataError: Bool = false
    internal var appendDataError: Bool = false
    internal var bookmarkedMovieIds: Set<String> = .init()
    internal var currentPage: Int = 0
    internal let dbManager: DatabaseManager
    
    internal init(dbManager: DatabaseManager = .shared) {
        self.dbManager = dbManager
    }
    
    internal func fetchData() async {
        await MainActor.run { [weak self] in
            self?.isLoading = true
        }
        await dataFromEndpoint()
        await MainActor.run { [weak self] in
            self?.isLoading = false
        }
    }
    
    internal func prepareGenreForSearchView() async throws -> Array<Genre> {
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
        return genreForUI
    }
    
    internal func dataFromEndpointForGenreTabs() async {
        do {
            if try await dbManager.fetchGenresTab().isEmpty {
                let genre: [Genre] = try await prepareGenreForSearchView()
                await MainActor.run { [weak self] in
                    self?.genresForSearchView = genre
                }
            } else {
                let genreTabsFromDb = try await dbManager.fetchGenresTab()
                await MainActor.run { [weak self] in
                    self?.genresForSearchView = genreTabsFromDb
                }
            }
        } catch {
            await MainActor.run { [weak self] in
                self?.error = error
            }
        }
    }
    
    internal func prepareDataForSearchView(
        searchQuery: String,
        genre: String,
        page: String
    ) async throws -> Array<Movie> {
        let tokenData: Data = try KeychainManager.getData(key: KeychainManager.KeychainKey.token)
        let token: String = .init(decoding: tokenData, as: UTF8.self)
        var queryArray: Array<URLQueryItem> = [
            .init(name: "query", value: searchQuery),
            .init(name: "limit", value: "20"),
            .init(name: "page", value: page)
        ]
        if genre != "All" {
            queryArray.append(
                .init(
                    name: "genre",
                    value: genre
                )
            )
        }
        let listsResource: Resource<SearchResponse> = .init(
            url: URL.SearchResponseURL,
            method: .get(queryArray),
            token: token
        )
        let response: SearchResponse = try await Webservice().call(listsResource)
        let moviesForUI: Array<Movie> = response.data?
            .compactMap { details in
                guard let movieId: String = details.id,
                      let title: String = details.name,
                      let overview: String = details.overview,
                      let posterUrl: String = details.imageUrl,
                      let genres: String = details.genres?.joined(separator: ", ")
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
            await updateBookmarks()
            currentPage = 0
            if searchText.isEmpty {
                await MainActor.run { [weak self] in
                    self?.dataForSearchView = .init()
                }
            } else {
                let searchMovieData: Array<Movie> = try await prepareDataForSearchView(
                    searchQuery: searchText,
                    genre: selectedGenre.title,
                    page: String(currentPage)
                )
                let filtredMovie: [Movie] = searchMovieData.updateBookmarkedStatus(bookmarkedMovieIds: bookmarkedMovieIds)
                await MainActor.run { [weak self] in
                    self?.dataForSearchView = filtredMovie
                }
                if searchMovieData.isEmpty {
                    throw EndpointResponce.dataFromEndpoint
                }
            }
        } catch {
            await dateFromDatabase()
        }
    }
    
    private func dateFromDatabase() async {
        do {
            await updateBookmarks()
            let fetchMovie: Array<Movie> = try await dbManager.searchMovie(by: searchText)
            let filtredMovie: [Movie] = fetchMovie.updateBookmarkedStatus(bookmarkedMovieIds: bookmarkedMovieIds)
            await MainActor.run { [weak self] in
                self?.dataForSearchView = filtredMovie
            }
        } catch {
            fetchDataError = true
            await MainActor.run { [weak self] in
                self?.error = error
            }
        }
    }
    
    internal func appendDataFromEndpoint() async throws {
        do {
            currentPage += 1
            let searchMovieData: Array<Movie> = try await prepareDataForSearchView(
                searchQuery: searchText,
                genre: selectedGenre.title,
                page: String(currentPage)
            )
            await MainActor.run { [weak self] in
                self?.dataForSearchView.append(contentsOf: searchMovieData)
                isFetchingNextPage = true
            }
        } catch {
            appendDataError = true
            await MainActor.run { [weak self] in
                self?.error = error
            }
        }
    }
    
    internal func updateBookmarks() async {
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
                    dataForSearchView = dataForSearchView.map { movie in
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
                }            }
            await updateBookmarks()
        }
    }
    
    internal var filteredMovie: Array<Movie> {
        if searchText.isEmpty {
            []
        } else {
            dataForSearchView.filter {
                $0.title.localizedStandardContains(searchText) ||
                $0.genres.localizedStandardContains(searchText) ||
                $0.overview.localizedStandardContains(searchText) ||
                $0.genres.localizedStandardContains(selectedGenre.title)
            }
        }
    }
}
