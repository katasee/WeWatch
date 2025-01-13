//
//  AddMovieView.swift
//  WeWatch
//
//  Created by Anton on 05/01/2025.
//

import SwiftUI

internal struct AddMovieView: View {
    
    @StateObject internal var viewModel: AddMovieViewModel = .init()
    @State private var movieId: Int = 0
    @State private var title: String = ""
    @State private var overview: String = ""
    @State private var releaseDate: String = ""
    @State private var rating: Int = 0
    @State private var posterUrl: String = ""
    @SwiftUI.Environment(\.presentationMode) var mode: Binding<PresentationMode>
    
    internal var body: some View {
        VStack {
            TextField("title", text: $title)
                .disableAutocorrection(true)
            TextField("overview", text: $overview)
                .disableAutocorrection(true)
            TextField("releaseDate", text: $releaseDate)
                .disableAutocorrection(true)
            TextField("posterUrl", text: $posterUrl)
                .disableAutocorrection(true)
            Button(action: {
                    viewModel.saveDate(movield: self.movieId, title: self.title, overview: self.overview, releaseDate: self.releaseDate, rating: self.rating, posterUrl: self.posterUrl)
                self.mode.wrappedValue.dismiss()
            }, label:
                    { Text("Add movie") }
            )
        }
    }
}

internal struct addMovieView_Preview:
    PreviewProvider {
    static var previews: some View {
        AddMovieView()
    }
}
