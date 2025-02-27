//
//  BookmarkViewModel.swift
//  WeWatch
//
//  Created by Anton on 27/01/2025.
//

import Foundation

internal final class BookmarkViewModel: ObservableObject {
    
    @Published internal var searchText: String = ""
    @Published internal var dataForBookmarkView: Array<MovieCardPreviewModel> = []
    
    internal func prepareDataBookmarkView() {
        dataForBookmarkView = MovieCardPreviewModel.mock()
    }
    
    internal var filteredBookmarkedMovie: Array<MovieCardPreviewModel> {
        if searchText.isEmpty {
            dataForBookmarkView
        } else {
            dataForBookmarkView.filter {
                $0.title.localizedStandardContains(searchText) ||
//                $0.genres.localizedStandardContains(searchText) ||
                $0.storyline.localizedStandardContains(searchText) 
            }
        }
    }
}

