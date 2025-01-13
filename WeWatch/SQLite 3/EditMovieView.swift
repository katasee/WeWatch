//
//  EditMovieView.swift
//  WeWatch
//
//  Created by Anton on 09/01/2025.
//

import SwiftUI

internal struct EditMovieView: View {
    
    internal let dbManager = DBManager.shared
    @Binding var movieId: Int32
    @State var title: String = ""
    @State var overview: String = ""
    @State var releaseDate: String = ""
    @State var rating: Int = 0
    @State var posterUrl: String = ""
    @SwiftUI.Environment(\.presentationMode) var mode: Binding<PresentationMode>
    
    internal var body: some View {
        VStack {
            TextField("title", text: $title)
            TextField("overview", text: $overview)
            TextField("releaseDate", text: $releaseDate)
            TextField("posterUrl", text: $posterUrl)
            Button(action: {
                do {
                    try dbManager.updateMovie(movieId: Int(movieId), title: title, overview: overview, releaseDate: releaseDate, rating: rating, posterUrl: posterUrl)
                } catch {
                    print("error update button")
                }
                self.mode.wrappedValue.dismiss()
            }, label: {
                Text("Edit Movie")
            }) .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.top, 10)
                .padding(.bottom, 10)
        }.padding()
    }
}


struct EditMovieView_Preview: PreviewProvider {
    @State static var movieId: Int32 = 0
    static var previews: some View {
        EditMovieView(movieId: $movieId)
    }
}
