//
//  MovieListView.swift
//  WeWatch
//
//  Created by Anton on 23/01/2025.
//

import SwiftUI

internal struct SearchListView: View {
    
    @StateObject private var viewModel: HomeViewModel = .init()
    private let data: Array<DiscoveryPreviewModel>
    private let seeMoreButtonAction: @MainActor () -> Void
    private let chooseButtonAction: @MainActor (DiscoveryPreviewModel) -> Void
    private var isActive: Bool
    @Binding private var searchText: String
    
    internal init(
        data: Array<DiscoveryPreviewModel>,
        seeMoreButtonAction: @escaping @MainActor () -> Void,
        chooseButtonAction: @escaping @MainActor (DiscoveryPreviewModel) -> Void,
        isActive: Bool,
        searchText: Binding<String>
    ) {
        self.data = data
        self.seeMoreButtonAction = seeMoreButtonAction
        self.chooseButtonAction = chooseButtonAction
        self.isActive = isActive
        self._searchText = searchText
    }
    
    internal var filteredMovie: Array<DiscoveryPreviewModel> {
        if searchText.isEmpty {
            data
        } else {
            data.filter {
                $0.title.localizedStandardContains(searchText) ||
                $0.genres.localizedStandardContains(searchText) ||
                $0.storyline.localizedStandardContains(searchText)
            }
        }
    }
    
    internal var body: some View {
        HStack {
            Text("search.title")
                .foregroundColor(.whiteColor)
                .font(.poppinsBold30px)
            + Text(".")
                .foregroundColor(.fieryRed)
                .font(.poppinsBold30px)
            Spacer()
        }
        VStack(alignment: .leading) {
            SearchBar(searchText: $searchText)
            MovieCategoryView()
            Text("search.result: \(filteredMovie.count)")
                .font(.poppinsBold18px)
                .foregroundColor(.whiteColor)
            ForEach(filteredMovie) { model in
                Button {
                    chooseButtonAction(model)
                } label: {
                    MovieCard(
                        title: model.title,
                        ranking: model.rating,
                        genres: model.genres,
                        storyline: model.storyline,
                        imageUrl: model.image,
                        didTap: { isActive in }
                    )
                    .multilineTextAlignment(.leading)
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var text = ""
    SearchListView(data: DiscoveryPreviewModel.mock(), seeMoreButtonAction: {}, chooseButtonAction: { isActive in }, isActive: true, searchText: $text)
}
