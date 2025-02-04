//
//  HomeViewModel.swift
//  WeWatch
//
//  Created by Anton on 21/01/2025.
//

import Foundation

internal final class HomeViewModel: ObservableObject {
    
    @Published internal var dataForTodaysSelectionSectionView: Array<TodaySelectionPreviewModel> = []
    @Published internal var dataForDiscoveryPreviewModel: Array<MovieCardPreviewModel> = []
    
    internal func prepareDataTodaySelection() {
        dataForTodaysSelectionSectionView = TodaySelectionPreviewModel.mock()
            
    }
    
    internal func prepareDataDiscovery() {
        dataForDiscoveryPreviewModel = MovieCardPreviewModel.mock()
    }
    
    func randomData() -> String {
        let alphabet = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]
        let randomLetter = alphabet.randomElement()
        return randomLetter ?? "error"
    }
    
    func isNewDay() -> Bool {
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        let currentDateString = dateFormatter.string(from: currentDate)
        if let lastSaved = UserDefaults.standard.string(forKey: "lastDate") {
            if lastSaved == currentDateString {
                return true
            } else {
                UserDefaults.standard.setValue(currentDateString, forKey: "lastDate")
                return false
            }
        } else {
            UserDefaults.standard.setValue(currentDateString, forKey: "lastDate")
            return false
        }
    }
    
}
