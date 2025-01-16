////
////  EditMovieView.swift
////  WeWatch
////
////  Created by Anton on 09/01/2025.
////

import SwiftUI

internal struct EditMovieView: View {
    
    @StateObject internal var viewModel: EditMovieViewModel = .init()
    @SwiftUI.Environment(\.presentationMode) var mode: Binding<PresentationMode>
    private let movieId: Int
    internal init(movieId: Int) {
        self.movieId = movieId
    }
    
    internal var body: some View {
        VStack {
            TextField("title", text: $viewModel.title)
            TextField("overview", text: $viewModel.overview)
            TextField("releaseDate", text: $viewModel.releaseDate)
            TextField("posterUrl", text: $viewModel.posterUrl)
            Button {
                viewModel.updateDate(movieId: movieId)
                self.mode.wrappedValue.dismiss()
            } label: {
                Text("Edit Movie")
            } .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.top, 10)
                .padding(.bottom, 10)
        }.padding()
    }
}

#Preview {
    EditMovieView(movieId: 0)
}

