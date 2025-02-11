//
//  TodaysSelectionSectionView.swift
//  WeWatch
//
//  Created by Anton on 19/01/2025.
//

import SwiftUI
import SwiftData

internal struct TodaysSelectionSectionView: View {
    
    private let data: [Movie]
    private let chooseButtonAction: @MainActor (Movie) -> Void
    
    internal init(
        data: [Movie],
        chooseButtonAction: @escaping @MainActor (Movie) -> Void
    ) {
        self.data = data
        self.chooseButtonAction = chooseButtonAction
    }
    
    internal var body: some View {
        ZStack {
            Color.black
            VStack {
                HStack {
                    title
                    Spacer()
                }
                ScrollView(.horizontal, showsIndicators: true) {
                    HStack(spacing: 20) {
                        movieCardButton
                        
                    }
                }
            }
        }
        
    }
    
    private var title: some View {
        Text("todaySelection.title")
            .foregroundColor(.whiteColor)
            .font(.poppinsBold30px)
        + Text(". ")
            .foregroundColor(.fieryRed)
            .font(.poppinsBold30px)
    }
    
    private var movieCardButton: some View {
        ForEach(data.prefix(10)) { model in
            Button {
                chooseButtonAction(model)
            } label: {
                NavigationLink(destination: DetailsView()) {
                    MovieCardTopFive(
                        title: model.title,
                        ranking: Double(model.rating),
                        image: model.posterUrl,
                        didTap: { isActive in }
                    )
                }
            }
        }
        
    }
}

#Preview {
    TodaysSelectionSectionView(
        data: [
            Movie(movieId: "1", title: "zmndksnk cndsfjdbnsjdbsjd bjsbckdnckdnkcndk", overview: "goog", releaseDate: "asca", rating: 3, posterUrl: URL(string: "https://m.media-amazon.com/images/M/MV5BZjFhZmU5NzUtZTg4Zi00ZjRjLWI0YmQtODk2MzI4YjNhYTdkXkEyXkFqcGc@._V1_FMjpg_UX1000_.jpg"
                                                                                                                                                      )),
            Movie(movieId: "1", title: "zmndksnkcndknckdncdkcnkdnkcnkdckdnckdnkcndk", overview: "goog", releaseDate: "asca", rating: 3, posterUrl: URL(string: "https://m.media-amazon.com/images/M/MV5BZjFhZmU5NzUtZTg4Zi00ZjRjLWI0YmQtODk2MzI4YjNhYTdkXkEyXkFqcGc@._V1_FMjpg_UX1000_.jpg"
                                                                                                                                                       )),
            Movie(movieId: "1", title: "zmndksnkcndknckdncdkcnkdnkcnkdckdnckdnkcndk", overview: "goog", releaseDate: "asca", rating: 3, posterUrl: URL(string: "https://m.media-amazon.com/images/M/MV5BZjFhZmU5NzUtZTg4Zi00ZjRjLWI0YmQtODk2MzI4YjNhYTdkXkEyXkFqcGc@._V1_FMjpg_UX1000_.jpg"
                                                                                                                                                      ))
        ],
        chooseButtonAction: { movie in
            // Тут можете реалізувати якусь дію для вибраного фільму, наприклад:
            print("Обраний фільм: \(movie.title)")
        }
    )
}
