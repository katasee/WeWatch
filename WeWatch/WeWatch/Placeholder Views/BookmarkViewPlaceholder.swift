//
//  BookmarkViewPlaceholder.swift
//  WeWatch
//
//  Created by Anton on 29/12/2024.
//

import SwiftUI

internal struct BookmarkViewPlaceholder: View {
    
    internal var body: some View {
        ZStack {
            Color.darkGreyColor
                .ignoresSafeArea()
            Text("BookmarkView")
        }
    }
}

#Preview {
    BookmarkViewPlaceholder()
}
