//
//  TodaySelctionViewModel.swift
//  WeWatch
//
//  Created by Anton on 19/01/2025.
//

import SwiftUI

struct TodaySelctionViewModel: View {
    
    @State private var infoFromData: [ModelSelctionData] = ModelSelctionData.TodaySelctionData()
    
    internal var body: some View {
        VStack {
            HStack {
                Text("todaySelection.title")
                    .foregroundColor(.whiteColor)
                    .font(.poppinsBold30px)
                + Text(". ")
                    .foregroundColor(.fieryRed)
                    .font(.poppinsBold30px)
                Spacer()
            }
            ScrollView(.horizontal, showsIndicators: true, content: {
                HStack(spacing: 20) {
                    ForEach(infoFromData) { infoFromData in
                        Button( action: {}, label: {
                            MovieCardTopFive(
                                title: infoFromData.title,
                                ranking: Double(infoFromData.rating),
                                image: infoFromData.image
                            )
                        })
                    }
                }
            })
        }
    }
}

#Preview {
    TodaySelctionViewModel()
}
