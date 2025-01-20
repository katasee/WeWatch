//
//  DiscoveryViewModel.swift
//  WeWatch
//
//  Created by Anton on 19/01/2025.
//

import SwiftUI

internal struct DiscoveryViewModel: View {
    
    @State private var infoFromData: [ModelDiscoveryData] = ModelDiscoveryData.discoveryData()
    
    internal var body: some View {
        HStack {
            Text("splash.view.description.first.part.title")
                .foregroundColor(.whiteColor)
                .font(.poppinsBold30px)
            + Text(". ")
                .foregroundColor(.fieryRed)
                .font(.poppinsBold30px)
            Spacer()
            Button("SeeMore.button") {
            }
            .font(.poppinsRegular16px)
            .foregroundColor(.fieryRed)
        }
        ScrollView(content: {
            ForEach(infoFromData) { infoFromData in
                Button( action : {}, label: {
                    MovieCard(
                        title: infoFromData.title,
                        ranking: infoFromData.rating,
                        genres: infoFromData.genres,
                        storyline: infoFromData.storyline,
                        image: infoFromData.image
                    )
                    .multilineTextAlignment(.leading)
                })
            }
        })
    }
}

#Preview {
    DiscoveryViewModel()
}
