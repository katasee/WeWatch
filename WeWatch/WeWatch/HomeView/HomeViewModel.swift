//
//  HomeViewModel.swift
//  WeWatch
//
//  Created by Anton on 21/01/2025.
//

import Foundation

internal final class HomeViewModel: ObservableObject {
    
    @Published internal var dataForTodaysSelectionSectionView: Array<TodaySelectionPreviewModel> = []
    @Published internal var dataForDiscoveryPreviewModel: Array<DiscoveryPreviewModel> = []
    
    internal func prepareDataTodaySelection() {
        dataForTodaysSelectionSectionView = TodaySelectionPreviewModel.mock()
    }
    
    internal func prepareDataDiscovery() {
        dataForDiscoveryPreviewModel = DiscoveryPreviewModel.mock()
    }
}
