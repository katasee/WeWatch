//
//  RatingView.swift
//  WeWatch
//
//  Created by Anton on 28/12/2024.
//

import SwiftUI

internal struct RatingView: View {
    
    private let ranking: Double
    internal init(
        ranking: Double
    ) {
        self.ranking = ranking
    }
    internal var body: some View {
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
