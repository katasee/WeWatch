//
//  SearchViewModel.swift
//  WeWatch
//
//  Created by Anton on 24/01/2025.
//

import Foundation

internal final class SearchViewModel: ObservableObject {
    
    @Published internal var setOfGenres: Array<Genre> = []
    @Published internal var dataForSearchView: Array<DataMovieCardPreviewModel> = []
    @Published internal var searchText: String
    @Published internal var selectedGenre: Genre = .init(title: "")
    
    internal init(
        searchText: String
    ) {
        self.searchText = searchText
    }
    
    internal func prepareDataSearchView() {
        dataForSearchView = DataMovieCardPreviewModel.mock()
    }
    
    internal func allGenres() -> Array<Genre> {
        var availableGenres = DataMovieCardPreviewModel.mock()
            .map { $0.genres.trimmingCharacters(in: .whitespaces) }
            .joined(separator: ",")
            .components(separatedBy: ",")
            .sorted()
        
        availableGenres.append("All")
        
        let uniqueGenres = Set(availableGenres)
        
        return uniqueGenres.map { Genre(title: $0)}
    }
    
    internal func prepareUniqGenres() {
        setOfGenres = allGenres()
        if let firstGenre = setOfGenres.first {
            selectedGenre = firstGenre
        }
    }
    
    internal var filteredMovie: Array<DataMovieCardPreviewModel> {
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

