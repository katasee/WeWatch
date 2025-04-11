//
//  DetailSectionView.swift
//  WeWatch
//
//  Created by Anton on 29/01/2025.
//

import SwiftUI
import Kingfisher

internal struct DetailSectionView: View {
    
    internal var movie: Movie
    
    @State private var isLandscape: Bool = false
    
    
    internal var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                poster(for: UIScreen.main.bounds.size)
                VStack(alignment: .leading, spacing: 8) {
                    title
                    rating
                    genres
                    readMoreButton
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
            }
            .onRotate { newOrientation in
                self.isLandscape = newOrientation.isLandscape
            }
        }
    }
    
    private func poster(for size: CGSize) -> some View {
        KFImage(URL(string: movie.posterUrl))
            .resizable()
            .placeholder({
                ZStack {
                    Rectangle()
                        .loadingIndicator()
                }
            })
            .aspectRatio(contentMode: .fill)
            .frame(maxHeight: isLandscape ? 200 : 900)
            .clipped()
            .overlay(
                LinearGradient(
                    gradient: Gradient(colors: [Color.clear, Color.black]),
                    startPoint: .center,
                    endPoint: .bottom
                )
            )
    }
    
    
    private var title: some View {
        Text(movie.title)
            .foregroundColor(.whiteColor)
            .font(.poppinsBold30px)
    }
    
    private var rating: some View {
        HStack {
            Text("\(movie.rating, specifier: "%.1f")")
                .foregroundColor(Color.whiteColor)
                .font(.poppinsBold16px)
                .foregroundColor(.whiteColor)
            RatingView(ranking: movie.rating)
        }
    }
    
    private var genres: some View {
        Text("\(movie.genres)")
            .foregroundColor(Color.whiteColor)
            .font(.poppinsRegular14px)
    }
    
    private var readMoreButton: some View {
        ExpandableTextView(lineLimit: 2, movie: movie)
            .foregroundColor(Color.lightGreyColor)
    }
}
