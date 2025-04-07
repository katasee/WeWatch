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
    @Published internal var isOpenNewPage = false
    @Published internal var isLoading: Bool = false
    @Published var error: (any Error)?
    internal var fetchDataError: Bool = false
    internal var appendDataError: Bool = false
    internal var currentPage: Int = 0
    internal var bookmarkedMovieIds: Set<String> = .init()
    internal let dbManager: DatabaseManager
    
    internal init(dbManager: DatabaseManager = .shared) {
        self.dbManager = dbManager
    }
    
    fileprivate enum HomeViewModelError: Error {
        case insufficientData
    }
    
    internal func fetchData() async {
        await MainActor.run { [weak self] in
            self?.isLoading = true
        }
        await dataForTodaySelection()
        await movieForDiscoveryView()
        await MainActor.run { [weak self] in
            self?.isLoading = false
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
                await updateBookmarks()
                await MainActor.run { [weak self] in
                    discoverySection = discoverySection.map { movie in
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
//        currentPage += 1
        let moviesForUI: Array<Movie> = response.data?
            .compactMap { movieDetails in
                guard let id: String = movieDetails.id,
                      let title: String = movieDetails.name,
                      let overview: String = movieDetails.overview,
                      let posterUrl: String = movieDetails.imageUrl,
                      let genres: String = movieDetails.genres?.joined(separator: ", ")
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
    
    internal func movieForDiscoveryView() async {
        do {
            await updateBookmarks()
            currentPage = 0
            let discoveryMovieData: [Movie] = try await prepareDataDiscoverySection(page: String(currentPage))
            let filtredMovie: [Movie] = discoveryMovieData.updateBookmarkedStatus(bookmarkedMovieIds: bookmarkedMovieIds)
            try await MainActor.run { [weak self] in
                self?.discoverySection = filtredMovie
            }
                if discoveryMovieData.isEmpty {
                    throw EndpointResponce.dataFromEndpoint
                }
            
        } catch {
            await fetchAndUpdateDiscoverySection()
        }
    }
    
    internal func appendDataFromEndpoint() async {
//        await MainActor.run {
//            isFetchingNextPage = true
//        }
        do {
            currentPage += 1
            let discoveryMovieData: [Movie] = try await prepareDataDiscoverySection(page: String(currentPage))
            await MainActor.run { [weak self] in
                self?.discoverySection.append(contentsOf: discoveryMovieData)
                self?.isFetchingNextPage = true
            }
        } catch {
            appendDataError = true
            await MainActor.run { [weak self] in
                self?.error = error
            }
        }
    }
    
    internal func prepareDataTodaySelection(query: String) async throws -> Array<Movie> {
        var attempts: Int = 0
        let maxAttempts: Int = 5
        let tokenData: Data = try KeychainManager.getData(key: KeychainManager.KeychainKey.token)
        let token: String = .init(decoding: tokenData, as: UTF8.self)
        let searchResource: Resource<SearchResponse> = .init(
            url: URL.SearchResponseURL,
            method: .get([.init(name: "query", value: "\(query)")]),
            token: token
        )
        var response: SearchResponse = try await Webservice().call(searchResource)
        print(response.data?.count)
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
                      let overview: String = details.overview
                else { return nil }
                let genresArray: Array<String> = details.genres ?? []
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
        print(moviesForUI.count)
        for movie in moviesForUI {
            try await dbManager.insert(movie)
            try await dbManager.attachMovieToList(
                listId: Constans.todaySelectionList,
                movieId: movie.id
            )
        }
        print(moviesForUI.count)
        return moviesForUI
    }
    
    internal func refreshBookmarkedinTodaySelection(
        active: Bool,
        movieId: String
    ) {
        Task { [weak self] in
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
                await MainActor.run { [weak self] in
                    todaySelection = todaySelection.map { movie in
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
            await updateBookmarks()
        }
    }
    
    internal func dataForTodaySelection() async {
        if hasDateChanged() {
            do {
                await updateBookmarks()
                let todaySelectionData: [Movie] = try await prepareDataTodaySelection(query: randomData())
                let filtredMovie: [Movie] = todaySelectionData.updateBookmarkedStatus(bookmarkedMovieIds: bookmarkedMovieIds)
                try await MainActor.run { [weak self] in
                    self?.todaySelection = filtredMovie
                }
                if todaySelectionData.isEmpty {
                    throw EndpointResponce.dataFromEndpoint
                }
            } catch {
                await MainActor.run { [weak self] in
                    self?.error = error
                }
            }
        } else {
            await fetchAndUpdateTodaySelection()
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
    
    private func fetchAndUpdateTodaySelection() async {
        do {
            let fetchMovie = try await dbManager.fetchMovieByList(forList: Constans.todaySelectionList)
            let filtredMovie: [Movie] = fetchMovie.updateBookmarkedStatus(bookmarkedMovieIds: bookmarkedMovieIds)
            await MainActor.run { [weak self] in
                self?.todaySelection = filtredMovie
            }
        } catch {
            fetchDataError = true
            await MainActor.run { [weak self] in
                self?.error = error
            }
        }
    }
    
    private func fetchAndUpdateDiscoverySection() async {
        do {
            await updateBookmarks()
            let fetchMovie = try await dbManager.fetchMovieByList(forList: Constans.discoveryList)
            let filtredMovie: [Movie] = fetchMovie.updateBookmarkedStatus(bookmarkedMovieIds: bookmarkedMovieIds)
            await MainActor.run { [weak self] in
                self?.discoverySection = filtredMovie
            }
        } catch {
            fetchDataError = true
            await MainActor.run { [weak self] in
                self?.error = error
            }
        }
    }
}
