//
//  HomeViewModel.swift
//  WeWatch
//
//  Created by Anton on 21/01/2025.
//

import Foundation

internal final class HomeViewModel: ObservableObject {
    
    @Published internal var todaySelection: Array<Movie> = .init()
    @Published internal var discoverySection: Array<Movie> = .init()
    @Published internal var isFetchingNextPage = false
    internal var currentPage: Int = 0
    internal var bookmarkedMovieIds: Set<String> = .init()
    internal let dbManager: DatabaseManager = .shared
    
    fileprivate enum HomeViewModelError: Error {
        case insufficientData
    }
    
    internal func updateBookmarks() async {
        do {
            let bookmarked = try await dbManager.fetchMovieByList(forList: Constans.bookmarkList)
            let ids = Set(bookmarked.map { $0.id })
            await MainActor.run {
                self.bookmarkedMovieIds = ids
            }
        } catch {
            print("Error updating bookmarks: \(error)")
        }
    }
    
    func idFromDatabase() async throws {
        let movieIds = try await dbManager.fetchMovieByList(forList: Constans.bookmarkList).map { $0.id }
        await MainActor.run {
            self.bookmarkedMovieIds = Set(movieIds)
        }
    }
    
    internal func refreshBookmarked(
        active: Bool,
        movieId: String,
        selectedMovie: Movie
    ) async {
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
            await updateBookmarks()
            await MainActor.run {
                discoverySection = discoverySection.map { movie in
                    var updatedMovie = movie
                    if movie.id == movieId {
                        updatedMovie.isBookmarked = active
                    }
                    return updatedMovie
                }
            }
        } catch {
            print("Error adding bookmark: \(error)")
        }
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
            try await idFromDatabase()
            let discoveryMovieData: [Movie] = try await prepareDataDiscoverySection(page: String(currentPage))
            let filtredMovie = discoveryMovieData.map { movie -> Movie in
                var updateMovie = movie
                updateMovie.isBookmarked = bookmarkedMovieIds.contains(movie.id)
                return updateMovie
            }
            try await MainActor.run {
                self.discoverySection = filtredMovie
                if discoveryMovieData.isEmpty {
                    throw EndpointResponce.dataFromEndpoint
                }
            }
        } catch {
            let fetchMovie = try await dbManager.fetchMovieByList(forList: Constans.discoveryList)
            let filtredMovie = fetchMovie.map { movie -> Movie in
                var updateMovie = movie
                updateMovie.isBookmarked = bookmarkedMovieIds.contains(movie.id)
                return updateMovie
            }
            await MainActor.run {
                self.discoverySection = filtredMovie
                
            }
        }
    }
    
    internal func appendDateFromEndpoint() async throws {
        Task { @MainActor in
            isFetchingNextPage = true
        }
        let discoveryMovieData: [Movie] = try await prepareDataDiscoverySection(page: String(currentPage))
        await MainActor.run {
            self.discoverySection.append(contentsOf: discoveryMovieData)
        }
        await MainActor.run { [weak self] in
            self?.isFetchingNextPage = false
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
        while (response.data?.count ?? 0) < 10 && attempts < maxAttempts {
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
                      let image: String = details.imageUrl,
                      let overview: String = details.overview,
                      let genresArray: Array<String> = details.genres
                else { return nil }
                let genres: String = genresArray.joined(separator: ", ")
                return .init(
                    id: movieId,
                    title: title,
                    overview: overview,
                    rating: 3,
                    posterUrl: image,
                    genres: genres
                )
            } ?? []
        for movie in moviesForUI {
            try await dbManager.insert(movie)
            try await dbManager.attachMovieToList(
                listId: Constans.todaySelectionList,
                movieId: movie.id
            )
        }
        return moviesForUI
    }
    
    internal func refreshBookmarkedinTodaySelection(
        active: Bool,
        movieId: String
    ) async {
        do {
            if active {
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
            await MainActor.run {
                todaySelection = todaySelection.map { movie in
                    var updatedMovie = movie
                    if movie.id == movieId {
                        updatedMovie.isBookmarked = active
                    }
                    return updatedMovie
                }
            }
        } catch {
            print("Error adding bookmark: \(error)")
        }
        await updateBookmarks()
    }
    
    internal func dataForTodaySelection() async throws {
        do {
            try await idFromDatabase()
            let todaySelectionData: [Movie] = try await prepareDataTodaySelection(query: randomData())
            let filtredMovie = todaySelection.map { movie -> Movie in
                var updateMovie = movie
                updateMovie.isBookmarked = bookmarkedMovieIds.contains(movie.id)
                return updateMovie
            }
            try await MainActor.run {
                self.todaySelection = filtredMovie
                if todaySelection.isEmpty {
                    throw EndpointResponce.dataFromEndpoint
                }
            }
            if todaySelectionData.isEmpty {
                throw EndpointResponce.dataFromEndpoint
            }
        } catch {
            let fetchMovie = try await dbManager.fetchMovieByList(forList: Constans.discoveryList)
            let filtredMovie = fetchMovie.map { movie -> Movie in
                var updateMovie = movie
                updateMovie.isBookmarked = bookmarkedMovieIds.contains(movie.id)
                return updateMovie
            }
            await MainActor.run {
                self.todaySelection = filtredMovie
                
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
