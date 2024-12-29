//
//  Bookmark.swift
//  WeWatch
//
//  Created by Anton on 27/12/2024.
//

import SwiftUI

internal struct Bookmark: View {
    
    internal let isBookmarked: Bool
    
    internal init(
        
        bookmark: Bool = false
    ) {
        self.isBookmarked = bookmark
    }
    
    internal var body: some View {
        if isBookmarked == false {
            Image("bookmark-default-icon")
        } else {
            Image("bookmark-active-icon")
        }
    }
}

#Preview {
    Bookmark()
}
