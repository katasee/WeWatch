//
//  DetailSectionView.swift
//  WeWatch
//
//  Created by Anton on 29/01/2025.
//

import SwiftUI

internal struct DetailSectionView: View {
    
    internal var movie: MovieCardPreviewModel
    
    internal var body: some View {
        ZStack(alignment: .leading) {
            poster
            VStack(alignment: .leading) {
                title
                HStack {
                    rating
                    RatingView(ranking: movie.rating)
                }
                genres
                readMoreButton
            }
            .padding(16)
        }
    }
    
    private var poster: some View {
        AsyncImage(url: movie.image) { result in
            result.image?
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(minHeight: 932)
                .overlay(LinearGradient(gradient: Gradient(colors: [
                    Color.clear,
                    Color.darkColor,
                    Color.darkColor
                ]), startPoint: .top, endPoint: .bottom))
        }
    }
    
    private var title: some View {
        Text(movie.title)
            .foregroundColor(.whiteColor)
            .font(.poppinsBold30px)
    }
    
    private var rating: some View {
        Text("\(movie.rating, specifier: "%.1f")")
            .foregroundColor(Color.whiteColor)
            .font(.poppinsBold16px)
            .foregroundColor(.whiteColor)
    }
    
    private var genres: some View {
        Text(movie.genres)
            .foregroundColor(Color.whiteColor)
            .font(.poppinsRegular14px)
    }
    
    private var readMoreButton: some View {
        ReadMoreButtonView(lineLimit: 2, movie: movie)
            .foregroundColor(Color.lightGreyColor)
    }
}
