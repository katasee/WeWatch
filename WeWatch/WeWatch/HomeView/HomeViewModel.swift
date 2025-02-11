//
//  HomeViewModel.swift
//  WeWatch
//
//  Created by Anton on 21/01/2025.
//

import Foundation

internal final class  HomeViewModel: ObservableObject {
    
    let dbManager: DatabaseManager = .shared
    @Published internal var transferToDataBase: DomainModels = .init()
    @Published internal var dataForTodaysSelectionSectionView: [Movie] = []
    @Published internal var dataForDiscoveryPreviewModel: Array<MovieCardPreviewModel> = []
    
    internal func prepareDataTodaySelection() async throws -> [Movie] {
        do {
            let movie = try await WebService.getMovie(query: randomData())
            print(movie)
            let transferData = movie.data?.compactMap { details in
                if let movieId = details.id,
                   let title = details.name,
                   let overview = details.overview,
                   let releaseDate = details.year,
                   let posterUrl = details.imageUrl
                {
                    do {
                        try dbManager.insertMovie(
                            movieId: movieId,
                            title: title,
                            overview: overview,
                            releaseDate: releaseDate,
                            rating: 3,
                            posterUrl: String(contentsOf: posterUrl)
                        )
                    } catch {
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
                    print("error")
                    return nil
                }
            }
            guard let unwrapData = transferData else {
                throw vieModelError.invalidUnwrapping
            }
            await MainActor.run { [weak self] in
                self?.dataForTodaysSelectionSectionView = unwrapData
                print(unwrapData)
            }
        } catch {
            print(vieModelError.invalidDataFromEndpoint)
            throw vieModelError.invalidDataFromEndpoint
        }
        print(dataForTodaysSelectionSectionView)
        return dataForTodaysSelectionSectionView
    }
    
    internal func dateFromEndpoint() async {
        do {
            try await prepareDataTodaySelection()
        } catch {
            
        }
    }
    internal func dateFromDatabase() async throws  {
        try await MainActor.run { [weak self] in
            self?.dataForTodaysSelectionSectionView = try dbManager.getAllMovies()
            print(try dbManager.getAllMovies())
        }
    }
    
    internal func isNewDay() -> Bool {
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        let currentDateString: String = DateFormatter.localizedString(from: currentDate, dateStyle: .short, timeStyle: .none)
        if let lastSaved = UserDefaults.standard.string(forKey: "cachDateString") {
            print(lastSaved)
            if "10/02/2025" != currentDateString {
                UserDefaults.standard.setValue(currentDateString, forKey: "cachDateString")
                return true
            } else {
                print(currentDateString)
                return false
            }
        } else {
            UserDefaults.standard.setValue(currentDateString, forKey: "cachDateString")
            print(currentDateString)
            return true
        }
    }
    
    internal func checkDay() async throws  {
        if isNewDay() {
            try await dateFromEndpoint()
            print( try await dateFromEndpoint())
        } else {
            do {
                try await dateFromDatabase()
                print(try await dateFromDatabase())
            } catch {
                print("error")
            }
        }
    }
    
    internal func randomData() -> String {
        let alphabet = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]
        let randomLetter = alphabet.randomElement()
        print(randomLetter ?? "error")
        return randomLetter ?? "error"
        
    }
    
    enum vieModelError: Error {
        case invalidUnwrapping
        case invalidDataFromEndpoint
        case invalidDataFromDatabase
    }
    
    internal func prepareDataDiscovery() {
        dataForDiscoveryPreviewModel = MovieCardPreviewModel.mock()
    }
}
