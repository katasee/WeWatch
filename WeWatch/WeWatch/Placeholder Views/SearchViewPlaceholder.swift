//
//  SearchViewPlaceholder.swift
//  WeWatch
//
//  Created by Anton on 29/12/2024.
//

import SwiftUI

internal struct SearchViewPlaceholder: View {
    
    internal var body: some View {
        ZStack {
            Color.lightGreyColor
                .ignoresSafeArea()
            Text("SearchView")
        }
    }
}

#Preview {
    SearchViewPlaceholder()
}
