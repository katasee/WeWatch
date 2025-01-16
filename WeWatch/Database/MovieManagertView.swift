//
//  MovieManagertView.swift
//  WeWatch
//
//  Created by Anton on 06/01/2025.
//

import SwiftUI

internal struct MovieManagertView: View {
    
    @StateObject internal var viewModel: MovieManagertViewModel = .init()
    
    internal var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Spacer()
                    NavigationLink (destination: AddMovieView(), label: {
                        Text("Add movie")
                    })
                }
                List (viewModel.modelManager) { (model) in
                    HStack {
                        NavigationLink(
                            destination: EditMovieView(
                                movieId: model.movieId
                            )) {
                                Text(model.title)
                                Spacer()
                                Text(model.overview)
                                Spacer()
                                Text(model.posterUrl)
                                Spacer()
                                Text(model.releaseDate)
                                Spacer()
                                Text("\(model.rating)")
                                Button {
                                    viewModel.deleteDate(movieId: model.movieId)
                                    viewModel.getAllMovies()
                                } label: {
                                    Text("Delete")
                                        .foregroundColor(Color.red)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                    }
                }
            }.padding()
                .onAppear(perform: {
                    viewModel.getAllMovies()
                })
                .navigationBarTitle("Movies")
        }
    }
}

#Preview {
    MovieManagertView()
}
