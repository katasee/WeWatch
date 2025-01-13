//
//  NavigationView.swift
//  WeWatch
//
//  Created by Anton on 06/01/2025.
//

import SwiftUI

internal struct NavigationViews: View {
    
    @State private var modelManager: [Movie] = []
    @State private var movieSelected: Bool = false
    @State private var selectedMovieId: Int32 = 0
    internal let dbManager = DBManager.shared
    
    internal var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Spacer()
                    NavigationLink (destination: AddMovieView(), label: {
                        Text("Add movie")
                    })
                }
                NavigationLink(destination: EditMovieView(movieId: self.$selectedMovieId), isActive: self.$movieSelected) {
                }
                List (self.modelManager) { (model) in
                    HStack {
                        Text(model.title)
                        Spacer()
                        Text(model.overview)
                        Spacer()
                        Text(model.posterUrl)
                        Spacer()
                        Text(model.releaseDate)
                        Spacer()
                        Text("\(model.rating)")
                        Button(action: {
                            self.selectedMovieId = Int32(model.movieId)
                            self.movieSelected = true
                        }, label: {
                            Text("Edit")
                                .foregroundColor(Color.blue)
                        })
                        .buttonStyle(PlainButtonStyle())
                        Button(action: {
                            dbManager.deleteMovieById(movieId: model.movieId)
                            self.modelManager = dbManager.getAllMovies()
                        }, label: {
                            Text("Delete")
                                .foregroundColor(Color.red)
                        })
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }.padding()
                .onAppear(perform: {
                    self.modelManager = dbManager.getAllMovies()
                })
                .navigationBarTitle("Movies")
        }
    }
}

#Preview {
    NavigationViews()
}
