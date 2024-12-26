//
//  MovieCardDiscover.swift
//  WeWatch
//
//  Created by Anton on 26/12/2024.
//

import SwiftUI

struct MovieCardDiscover: View {
    
    private let title: String = .init()
    private let ranking: Double = .init()
    private var bookmark: Bool = false
    
    var body: some View {
        ZStack {
            Color.black
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
                    .frame(maxWidth: 182, maxHeight: 273, alignment: .topLeading)
                    .background(RoundedRectangle(cornerRadius: 15) .fill(Color.darkGreyColor))
                    Text(title)
                    HStack {
                        Text("\(ranking, specifier: "%.1f")")
                        Image("star-full-icon")
                    }
                    .font(.poppinsRegular18px)
                }
                .font(.poppinsBold18px)
                .foregroundColor(.whiteColor)
        }
    }
}

#Preview {
    MovieCardDiscover()
}
