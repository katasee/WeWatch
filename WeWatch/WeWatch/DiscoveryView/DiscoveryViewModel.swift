//
//  DiscoveryViewModel.swift
//  WeWatch
//
//  Created by Anton on 17/02/2025.
//
//

import Foundation

internal final class DiscoveryViewModel: ObservableObject {
    
    @Published internal var dataForAllMovieTab: Array<Movie> = []
    @Published internal var genresForDiscoveryView: Array<Genre> = []
    @Published internal var selectedGenre: Genre = .init(id: "0", title: "All")
    @Published internal var isFetchingNextPage = false
    
    internal var isFirstTimeLoad: Bool = true
    internal var currentPage: Int = 0
    internal var isBackEndDateEmpty: Bool = false
    private let dbManager: DatabaseManager
    
    internal init(dbManager: DatabaseManager) {
        self.dbManager = dbManager
    }
    
    internal func dataFromEndpoint() async {
        await MainActor.run { [weak self] in
            self?.dataForAllMovieTab = []
            self?.currentPage = 0
        }
        do {
            let discoveryMovieData: Array<Movie> = try await prepareDataForDiscoveryView(
                genre: filterGenres(),
                page: String(currentPage)
            )
            await MainActor.run { [weak self] in
                self?.dataForAllMovieTab = discoveryMovieData
            }
            if discoveryMovieData.isEmpty {
                throw EndpointResponce.dataFromEndpoint
            }
        } catch {
            await movieDataFromDatabase()
        }
    }
    
    internal func movieDataFromDatabase() async {
        do {
            let moviesFromDb: Array<Movie> = try await dbManager.fetchMovieByGenres(
                forGenre: filterGenres()
            ).compactMap { movie in
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
            print("Error in movieDataFromDatabase: \(error)")
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
        currentPage += 1
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
        if isFirstTimeLoad || isFetchingNextPage {
            isFirstTimeLoad = false
            return
        }
        Task { @MainActor in
            isFetchingNextPage = true
        }
        Task {
            do {
                let discoveryMovieData: [Movie] = try await prepareDataForDiscoveryView(
                    genre: selectedGenre.title,
                    page: String(currentPage)
                )
                if discoveryMovieData.isEmpty {
                    await MainActor.run { [weak self] in
                        self?.isBackEndDateEmpty = true
                    }
                } else {
                    await MainActor.run { [weak self] in
                        self?.isBackEndDateEmpty = false
                        self?.dataForAllMovieTab.append(contentsOf: discoveryMovieData)
                    }
                }
            } catch {
                print("Error in fetchNextPage: \(error)")
            }
            await MainActor.run { [weak self] in
                self?.isFetchingNextPage = false
            }
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
                try await dbManager.insert(genre)
                try await dbManager.attachListOfGenre(
                    genreId: genre.id,
                    name: genre.title
                )
            } catch {
                print("Error inserting genre: \(error)")
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
            print("Error in dataFromEndpointForGenreTabs: \(error)")
        }
    }
    
    internal func filterGenres() -> String {
        let chooseGenre: String = selectedGenre.title
        return chooseGenre
    }
}
