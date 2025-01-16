//
//  AddMovieView.swift
//  WeWatch
//
//  Created by Anton on 05/01/2025.
//

import SwiftUI

internal struct AddMovieView: View {
    
    @StateObject internal var viewModel: AddMovieViewModel = .init()
    
    @SwiftUI.Environment(\.presentationMode) var mode: Binding<PresentationMode>
    
    internal var body: some View {
        VStack {
            TextField("title", text: $viewModel.title)
                .disableAutocorrection(true)
            TextField("overview", text: $viewModel.overview)
                .disableAutocorrection(true)
            TextField("releaseDate", text: $viewModel.releaseDate)
                .disableAutocorrection(true)
            TextField("posterUrl", text: $viewModel.posterUrl)
                .disableAutocorrection(true)
            Button {
                viewModel.saveDate()
                self.mode.wrappedValue.dismiss()
            } label:
            { Text("Add movie") }
        }
    }
}

#Preview {
    AddMovieView()
}
