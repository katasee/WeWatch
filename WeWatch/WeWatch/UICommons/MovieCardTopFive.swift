//
//  MovieCardTopFive.swift
//  WeWatch
//
//  Created by Anton on 26/12/2024.
//

import SwiftUI

struct MovieCardTopFive: View {
    
    private var bookmark: Bool = false
    private let title: String = .init()
    private let ranking: Double = .init()
    var body: some View {
        VStack(alignment: .leading) {
            HStack() {
                Spacer()
                if bookmark == false {
                    Image("bookmark-default-icon")
                } else {
                    Image("bookmark-active-icon")
                }
            }
            .padding()
            .frame(maxWidth: 300, maxHeight: 200, alignment: .topLeading)
            .background(RoundedRectangle(cornerRadius: 15) .fill(Color.darkGreyColor))
            Text(title)
                .font(.poppinsBold20px)
                .foregroundColor(.whiteColor)
            HStack {
                Text("\(ranking, specifier: "%.1f")")                            .font(.poppinsRegular22px)
                    .foregroundColor(.whiteColor)
                RatingView(ranking: ranking)
            }
        }
    }
}

#Preview {
    MovieCardTopFive()
}
