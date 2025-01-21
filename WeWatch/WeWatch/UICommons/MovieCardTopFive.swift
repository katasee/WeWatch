//
//  MovieCardTopFive.swift
//  WeWatch
//
//  Created by Anton on 26/12/2024.
//

import SwiftUI

internal struct MovieCardTopFive: View {
    
    @State private var isActive: Bool = false
    private let title: String
    private let ranking: Double
    private let imageUrl: URL?
    private var didTap: @MainActor (Bool) -> Void
    
    internal init(
        title: String,
        ranking: Double,
        image: URL?,
        didTap: @escaping @MainActor (Bool) -> Void
    ) {
        self.title = title
        self.ranking = ranking
        self.imageUrl = image
        self.didTap = didTap
    }
    
    internal var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    ZStack(alignment: .topTrailing) {
                        AsyncImage(url: imageUrl) {
                            image in
                            image
                                .image?.resizable()
                        }
                        Button {
                            isActive.toggle()
                            didTap(isActive)
                        } label: {
                            if isActive == true {
                                Bookmark(isActive: true)
                            } else {
                                Bookmark(isActive: false)
                            }
                        }
                        .padding(16)
                    }
                    .cornerRadius(15)
                    .frame(maxWidth: 300, maxHeight: 200)
                    .background(RoundedRectangle(cornerRadius: 15)
                        .fill(Color.darkGreyColor))
                }
                filmTitle
            }
            HStack {
                filmRanking
                RatingView(ranking: ranking)
            }
        }
    }
    
    private var filmRanking: some View {
        Text("\(ranking, specifier: "%.1f")")
            .font(.poppinsRegular22px)
            .foregroundColor(.whiteColor)
    }
    
    private var filmTitle: some View {
        Text(title)
            .font(.poppinsBold20px)
            .foregroundColor(.whiteColor)
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea();
        MovieCardTopFive(
            title: "Hitman’s Wife’s Bodyguard",
            ranking: 3.5,
            image: URL(string: "https://miro.medium.com/v2/resize:fit:4800/format:webp/1*39M4XbHXCTfBenNNqLLyLA@2x.jpeg"),
            didTap: { isActive in }
        )
    }
}
