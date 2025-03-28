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
//    @Published internal var bookmarkMovie: Array<Movie> = .init()
    internal var currentPage: Int = .init()
    internal var dbManager: DatabaseManager = .init(dataBaseName: DatabaseConfig.name)
    internal var bookmarkedMovieIds: Set<String> = .init()
    
    init(
        dbManager: DatabaseManager
    ) {
        self.dbManager = dbManager
    }
    
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
        await MainActor.run { [weak self] in
            self?.bookmarkedMovieIds = Set(movieIds)
        }
    }
    
    internal func refreshBookmarked(active: Bool, movieId: String) async {
        do {
            if active {
                try await dbManager.attachMovieToList(
                    listId: Constans.bookmarkList,
                    movieId: movieId
                )
//                bookmarkedMovieIds.insert(movieId)

            } else {
                try await dbManager.detachMovieFromList(
                    listId: Constans.bookmarkList,
                    movieId: movieId
                )
//                bookmarkedMovieIds.remove(movieId)
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
           let filtredMovie = discoveryMovieData.map { movie in
                var mutableMovie = movie
                mutableMovie.isBookmarked = bookmarkedMovieIds.contains(movie.id)
               print(bookmarkedMovieIds)
                    return mutableMovie
            }
            try await MainActor.run { [weak self] in
                self?.discoverySection = filtredMovie
                if discoveryMovieData.isEmpty {
                    throw EndpointResponce.dataFromEndpoint
                }
            }
        } catch {
            let fetchMovie = try await dbManager.fetchMovieByList(forList: Constans.discoveryList)
            let filtredMovie = fetchMovie.map { movie in
                var mutableMovie = movie
                mutableMovie.isBookmarked = bookmarkedMovieIds.contains(movie.id)
                    return mutableMovie
            }
            await MainActor.run { [weak self] in
                self?.discoverySection = filtredMovie
                
            }
        }
    }
    
    internal func appendDateFromEndpoint() async throws {
        let discoveryMovieData: [Movie] = try await prepareDataDiscoverySection(page: String(currentPage))
        await MainActor.run { [weak self] in
            self?.discoverySection.append(contentsOf: discoveryMovieData)
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
                      let image: String = details.imageUrl,
                      let overview: String = details.overview,
                      let genreses: Array<String> = details.genres
                else {
                    return nil
                }
                let genres: String = genreses
                    .joined(separator: ", ")
                return .init(
                    id: movieId,
                    title: title,
                    overview: overview,
                    rating: 3,
                    posterUrl: image,
                    genres: genres
                )
            } ?? .init()
        for movie in moviesForUI {
            try await dbManager.insert(movie)
            try await dbManager.attachMovieToList(listId: Constans.todaySelectionList, movieId: movie.id)
        }
        return moviesForUI
    }
    
    internal func dataForTodaySelection() async throws {
        do {
            let todaySelectionData: [Movie] = try await prepareDataTodaySelection(query: randomData())
            await MainActor.run { [weak self] in
                self?.todaySelection = todaySelectionData
            }
            if todaySelectionData.isEmpty {
                throw EndpointResponce.dataFromEndpoint
            }
        } catch {
            let fetchMovie = try await dbManager.fetchMovieByList(forList: Constans.discoveryList)
            await MainActor.run { [weak self] in
                self?.todaySelection = fetchMovie
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

//    internal func addBookmark(movieId: String) async {
//        do {
//          try await dbManager.attachMovieToList(
//                listId: Constans.bookmarkList,
//                movieId: movieId
//            )
//            let dbList = try await dbManager.fetchMovieByList(forList: Constans.bookmarkList)
//            let filterMovie = dbList.map { movie in
//                var mutableMovie = movie
//                mutableMovie.isBookmarked = bookmarkedMovieIds.contains(movie.id)
//                print(bookmarkedMovieIds)
//                return mutableMovie
//            }
//
//        } catch {
//            print(error)
//        }
//    }
//
//    internal func removeBookmark(movieId: String) async {
//        do {
//            try await dbManager.delete(
//                from: Movie.self,
//                id: movieId
//            )
//
//            print(bookmarkedMovieIds)
//        } catch {
//            print(error)
//        }
//    }
