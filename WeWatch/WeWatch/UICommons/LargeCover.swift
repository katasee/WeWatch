//
//  LargeCover.swift
//  WeWatch
//
//  Created by Anton on 27/12/2024.
//

import SwiftUI

struct LargeCover: View {

    var body: some View {
        ZStack {
            Image("photo")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea()
                .frame(minWidth: 0, idealWidth: .infinity)
        }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea();
        LargeCover()
    }
}
