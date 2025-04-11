//
//  MovieCategoryView.swift
//  WeWatch
//
//  Created by Anton on 22/01/2025.
//

import SwiftUI

internal struct MovieCategoryView: View {
    
    private let selectedGenre: Genre
    private let genreTabs: Array<Genre>
    private let action: (Genre) -> Void
    
    internal init(
        genreTabs: Array<Genre>,
        selectedGenre: Genre,
        action: @escaping (Genre) -> Void
    ) {
        self.genreTabs = genreTabs
        self.selectedGenre = selectedGenre
        self.action = action
    }
    
    internal var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(genreTabs, id: \.self) { tab in
                    PillButton(
                        isActive: tab == selectedGenre,
                        title: tab.title,
                        action: {
                            action(tab)
                        }
                    )
                }
            }
        }
        .padding(7)
    }
}
