//
//  SearchViewModel.swift
//  WeWatch
//
//  Created by Anton on 24/01/2025.
//

import Foundation

internal final class SearchViewModel: ObservableObject {
    
    @Published internal var setOfGenres: Array<Genre> = []
    @Published internal var dataForSearchView: Array<MovieCardPreviewModel> = []
    @Published internal var searchText: String = ""
    @Published internal var selectedGenre: Genre = .init(id: "", title: "")
    
    internal func prepareDataSearchView() {
        dataForSearchView = MovieCardPreviewModel.mock()
    }
    
    internal func allGenres() -> Array<Genre> {
        var availableGenres = MovieCardPreviewModel.mock()
            .map { $0.genres.trimmingCharacters(in: .whitespaces) }
            .joined(separator: ",")
            .components(separatedBy: ",")
            .sorted()
        
        availableGenres.append("All")
        
        let uniqueGenres = Set(availableGenres)
        
        return uniqueGenres.map { Genre(id: $0, title: $0)}
    }
    
    internal func prepareUniqGenres() {
        setOfGenres = allGenres()
        if let firstGenre = setOfGenres.first {
            selectedGenre = firstGenre
        }
    }
    
    internal var filteredMovie: Array<MovieCardPreviewModel> {
        if searchText.isEmpty {
            dataForSearchView
        } else {
            dataForSearchView.filter {
                $0.title.localizedStandardContains(searchText) ||
                $0.genres.localizedStandardContains(searchText) ||
                $0.storyline.localizedStandardContains(searchText) ||
                $0.genres.localizedStandardContains(selectedGenre.title)
            }
        }
    }
}

