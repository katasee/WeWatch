//
//  MovieCard.swift
//  WeWatch
//
//  Created by Anton on 26/12/2024.
//

import SwiftUI

struct MovieCard: View {
    
    private let title: String = .init()
    private var bookmark: Bool = false
    private let ranking: Double = .init()
    private var emptyStar: Image = .init("star-empty-icon")
    private var fullStar: Image = .init("star-full-icon")
    private var halfStar: Image = .init("star-half-icon")
    private var genres: String = .init()
    private var storyline: String = .init()
    
    var body: some View {
        HStack(alignment: .top) {
            VStack {
                HStack {
                    Spacer()
                    if bookmark == false {
                        Image("bookmark-active-icon")
                    } else {
                        Image("bookmark-active-icon")
                    }
                }
                .padding()
                .frame(maxWidth: 182, maxHeight: 273, alignment: .topLeading)
                .background(RoundedRectangle(cornerRadius: 15) .fill(Color.darkGreyColor))
            }
            VStack {
                Text(title)
                    .font(.poppinsBold20px)
                    .foregroundColor(.whiteColor)
                HStack {
                    Text("\(ranking, specifier: "%.1f")")                            .font(.poppinsBold16px)
                        .foregroundColor(.whiteColor)
                    RatingView(ranking: ranking)
                }
                Text(genres)
                    .font(.poppinsBold14px)
                    .foregroundColor(.whiteColor)
                Text(storyline)
                    .font(.poppinsRegular13px)
                    .foregroundColor(.lightGreyColor)
            }
        }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea();
        MovieCard()
    }
}

struct RatingView: View {
    let ranking: Double
    var body: some View {
        ForEach(0..<5, id: \.self) { index in
            if Double(index) + 1 <= ranking {
                Image("star-full-icon")
                    .resizable()
                    .frame(width: 20, height: 20)
            } else if Double(index) + 0.5 <= ranking {
                Image("star-half-icon")
                    .resizable()
                    .frame(width: 20, height: 20)
            } else  {
                Image("star-empty-icon")
                    .resizable()
                    .frame(width: 20, height: 20)
            }
        }
    }
}
