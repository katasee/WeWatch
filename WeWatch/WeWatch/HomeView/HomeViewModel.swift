//
//  HomeViewModel.swift
//  WeWatch
//
//  Created by Anton on 21/01/2025.
//

import Foundation

internal final class  HomeViewModel: ObservableObject {
    
    internal let dbManager: DatabaseManager = .shared
    @Published internal var transferToDataBase: DomainModels = .init()
    @Published internal var dataForTodaysSelectionSectionView: [Movie] = []
    @Published internal var dataForDiscoveryPreviewModel: Array<MovieCardPreviewModel> = []
    
    internal func prepareDataTodaySelection() async throws -> [Movie] {
        do {
            var movie: DomainModels = try await WebService.getMovie(query: randomData())
            while (movie.data?.count ?? 0) < 10 {
                movie = try await WebService.getMovie(query: randomData())
            }
            let transferData: [Movie]? =  movie.data?.compactMap { details in
                if let movieId: String = details.id,
                   let title: String = details.name,
                   let overview: String = details.overview,
                   let releaseDate: String = details.year,
                   let posterUrl: String = details.imageUrl
                {
                    do {
                        try dbManager.insertMovie(
                            movieId: movieId,
                            title: title,
                            overview: overview,
                            releaseDate: releaseDate,
                            rating: 3,
                            posterUrl: posterUrl
                        )
                    } catch {
                        print(error)
                    }
                    return Movie(
                        movieId: movieId,
                        title: title,
                        overview: overview,
                        releaseDate: releaseDate,
                        rating: 3,
                        posterUrl: posterUrl
                    )
                } else {
                    return nil
                }
            }
            guard let unwrapData: [Movie] = transferData else {
                throw vieModelError.invalidUnwrapping
            }
            await MainActor.run { [weak self] in
                self?.dataForTodaysSelectionSectionView = unwrapData
            }
        } catch {
            throw vieModelError.invalidDataFromEndpoint
        }
        return dataForTodaysSelectionSectionView
    }
    
    internal func dateFromEndpoint() async throws {
        do {
            try await prepareDataTodaySelection()
        } catch {
            print(error)
        }
    }
    
    internal func dateFromDatabase() async throws {
        try await MainActor.run { [weak self] in
            self?.dataForTodaysSelectionSectionView = try dbManager.getAllMovies()
        }
    }
    
    internal func isNewDay() -> Bool {
        let currentDate: Date = Date()
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        let currentDateString: String = DateFormatter.localizedString(
            from: currentDate,
            dateStyle: .short,
            timeStyle: .none
        )
        if let lastDate: String = UserDefaults.standard.string(forKey: "cachDateString") {
            if lastDate != currentDateString {
                UserDefaults.standard.setValue(currentDateString, forKey: "cachDateString")
                return true
            } else {
                return false
            }
        } else {
            UserDefaults.standard.setValue(currentDateString, forKey: "cachDateString")
            return true
        }
    }
    
    internal func dateCheck() async throws {
        if isNewDay() {
            try await dateFromEndpoint()
        } else {
            do {
                try await dateFromDatabase()
            } catch {
                print(error)
            }
        }
    }
    
    internal func randomData() -> String {
        let alphabet: [String] = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]
        let randomLetter: String? = alphabet.randomElement()
        return randomLetter ?? "error"
    }
    
    enum vieModelError: Error {
        case invalidUnwrapping
        case invalidDataFromEndpoint
    }
    
    func date() async {
        if dataForTodaysSelectionSectionView.count < 10 {
            do {
                try await dateCheck()
            } catch {
            }
        }
    }
    
    internal func prepareDataDiscovery() {
        dataForDiscoveryPreviewModel = MovieCardPreviewModel.mock()
    }
}
