//
//  SearchView.swift
//  WeWatch
//
//  Created by Anton on 22/01/2025.
//

import SwiftUI

internal struct SearchView: View {
    
    @StateObject private var viewModel: SearchViewModel = .init()
    @Binding private var searchText: String
    
    internal init(searchText: Binding<String>) {
        self._searchText = searchText
    }
    
    internal var body: some View {
        ZStack {
            Color(.black)
                .ignoresSafeArea()
            ScrollView {
                VStack {
                    SearchListView( data: viewModel.dataForSearchView,
                                    seeMoreButtonAction: {},
                                    chooseButtonAction: { isActive in },
                                    // noop
                                    isActive: true, searchText: $searchText)
                }
                .padding(16)
            }
            .onAppear {
                viewModel.prepareDataSearchView()
            }
        }
    }
}

#Preview {
    @Previewable @State var text = ""
    return SearchView(
        searchText: $text)
}
