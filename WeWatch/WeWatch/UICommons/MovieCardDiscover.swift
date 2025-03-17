//
//  MovieCardDiscover.swift
//  WeWatch
//
//  Created by Anton on 26/12/2024.
//

import SwiftUI
import Kingfisher


internal struct MovieCardDiscover: View {
    
    @State private var isActive: Bool
    @State private var isLoading: Bool = true
    private let title: String
    private let ranking: Double
    private let imageUrl: URL?
    private var didTap: @MainActor (Bool) -> Void
    
    
    internal init(
        isActive: Bool,
        title: String,
        ranking: Double,
        imageUrl: URL?,
        didTap: @escaping @MainActor (Bool) -> Void
    ) {
        self.isActive = isActive
        self.title = title
        self.ranking = ranking
        self.imageUrl = imageUrl
        self.didTap = didTap
    }
    
    internal var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            ZStack(alignment: .topTrailing) {
                filmImage
                Spacer()
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
            Text(title)
                .font(.poppinsBold18px)
                .lineLimit(1)
            HStack {
                filmRanking
                Image("star-full-icon")
            }
        }
        .foregroundColor(.whiteColor)
        .frame(maxWidth: 182)
    }
    
    private var filmRanking: some View {
        Text("\(ranking, specifier: "%.1f")")
            .font(.poppinsRegular18px)
    }
    
    private var filmImage: some View {
        KFImage(imageUrl)
            .resizable()
            .placeholder({
                ZStack {
                    Rectangle()
                        .loadingIndicator()
                }
            })
            .cornerRadius(15)
            .frame(maxWidth: 182, maxHeight: 273)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.darkGreyColor)
            )
    }
}
