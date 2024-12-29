//
//  ImagePlaceholder.swift
//  WeWatch
//
//  Created by Anton on 27/12/2024.
//

import SwiftUI

internal struct ImagePlaceholder: View {
    
    internal var body: some View {
        ZStack {
            Image("photo")
                .resizable()
                .ignoresSafeArea()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .cornerRadius(15)
                .background(Color.dakrGrey)
        }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        ImagePlaceholder()
    }
}
