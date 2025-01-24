//
//  SearchViewModel.swift
//  WeWatch
//
//  Created by Anton on 24/01/2025.
//

import Foundation

internal final class SearchViewModel: ObservableObject {
    
    @Published internal var dataForSearchView: Array<DiscoveryPreviewModel> = []
    
    internal func prepareDataSearchView() {
        dataForSearchView = DiscoveryPreviewModel.mockForSearchView()
    }
}
