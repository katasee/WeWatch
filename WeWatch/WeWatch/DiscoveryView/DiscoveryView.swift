//
//  DiscoveryView.swift
//  WeWatch
//
//  Created by Anton on 16/02/2025.
//

import SwiftUI

internal struct DiscoveryView: View {
    
    @StateObject private var viewModel: DetailsViewModel = .init()
    
    internal var body: some View {
        ZStack {
        BackButton()
        NavigationView {
                    DiscoveryListView(data: [
                        DiscoveryPreviewModel(id: 1, title: "Inception", rating: 8.8, image: URL(string: "https://m.media-amazon.com/images/M/MV5BZjFhZmU5NzUtZTg4Zi00ZjRjLWI0YmQtODk2MzI4YjNhYTdkXkEyXkFqcGc@._V1_FMjpg_UX1000_.jpg")),
                        DiscoveryPreviewModel(id: 2, title: "Inception", rating: 8.8, image: URL(string: "https://m.media-amazon.com/images/M/MV5BZjFhZmU5NzUtZTg4Zi00ZjRjLWI0YmQtODk2MzI4YjNhYTdkXkEyXkFqcGc@._V1_FMjpg_UX1000_.jpg")),
                        DiscoveryPreviewModel(id: 3, title: "Inception", rating: 8.8, image: URL(string: "https://m.media-amazon.com/images/M/MV5BZjFhZmU5NzUtZTg4Zi00ZjRjLWI0YmQtODk2MzI4YjNhYTdkXkEyXkFqcGc@._V1_FMjpg_UX1000_.jpg")),
                        DiscoveryPreviewModel(id: 4, title: "Inception", rating: 8.8, image: URL(string: "https://m.media-amazon.com/images/M/MV5BZjFhZmU5NzUtZTg4Zi00ZjRjLWI0YmQtODk2MzI4YjNhYTdkXkEyXkFqcGc@._V1_FMjpg_UX1000_.jpg")),
                        DiscoveryPreviewModel(id: 5, title: "Inception", rating: 8.8, image: URL(string: "https://m.media-amazon.com/images/M/MV5BZjFhZmU5NzUtZTg4Zi00ZjRjLWI0YmQtODk2MzI4YjNhYTdkXkEyXkFqcGc@._V1_FMjpg_UX1000_.jpg")),
                        DiscoveryPreviewModel(id: 6, title: "Inception", rating: 8.8, image: URL(string: "https://m.media-amazon.com/images/M/MV5BZjFhZmU5NzUtZTg4Zi00ZjRjLWI0YmQtODk2MzI4YjNhYTdkXkEyXkFqcGc@._V1_FMjpg_UX1000_.jpg")),
                        
                    ],
                                      chooseButtonAction: { _ in }, selectedGenre: Genre(title: "Comedy"), setOfGenre: [ Genre(title: "Comedy"), Genre(title: "Horror"), Genre(title: "Action")],  selectGenreAction: { _ in } )
                }
            }
        }
    }



#Preview {
    DiscoveryView()
}
