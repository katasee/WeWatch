//
//  SearchViewModel.swift
//  WeWatch
//
//  Created by Anton on 24/01/2025.
//

import Foundation

internal final class SearchViewModel: ObservableObject {
    
    @Published internal var genresForSearchView: Array<Genre> = []
    @Published internal var dataForSearchView: Array<Movie> = []
    @Published internal var searchText: String = ""
    @Published internal var selectedGenre: Genre = .init(id: "0", title: "All")
    @Published internal var isFetchingNextPage = false
    internal var currentPage: Int = 0
    
    
    
    private let dbManager: DatabaseManager
    
    internal init(dbManager: DatabaseManager) {
        self.dbManager = dbManager
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
            print("Error in dataFromEndpointForGenreTabs: \(error)")
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
    
    internal func prepareDataForSearchView(searchQuery: String, genre: String, page: String) async throws -> Array<Movie> {
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
        return moviesForUI
    }
    
    internal func dataFromEndpoint() async {
        currentPage = 0
        if searchText.isEmpty {
            await MainActor.run { [weak self] in
                self?.dataForSearchView = []
            }
        } else {
            do {
                let searchMovieData: Array<Movie> = try await prepareDataForSearchView(
                    searchQuery: searchText,
                    genre: selectedGenre.title,
                    page: String(currentPage)
                )
                await MainActor.run { [weak self] in
                    self?.dataForSearchView = searchMovieData
                }
                if searchMovieData.isEmpty {
                    throw EndpointResponce.dataFromEndpoint
                }
            } catch {
                await dateFromDatabase()
            }
        }
    }
    
    private func dateFromDatabase() async {
        do {
            let movie: Array<Movie> = try await dbManager.searchMovie(by: searchText)
            await MainActor.run { [weak self] in
                self?.dataForSearchView = movie
            }
        } catch {
            DatabaseError.fetchError(message: "Error fetch movie by id")
        }
    }
    
    internal func appendDateFromEndpoint() async throws {
        currentPage += 1
        let searchMovieData: Array<Movie> = try await prepareDataForSearchView(
            searchQuery: searchText,
            genre: selectedGenre.title,
            page: String(currentPage)
        )
        await MainActor.run { [weak self] in
        isFetchingNextPage = true
            self?.dataForSearchView.append(contentsOf: searchMovieData)
        }
    }
}

