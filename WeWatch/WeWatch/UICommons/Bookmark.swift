//
//  Bookmark.swift
//  WeWatch
//
//  Created by Anton on 27/12/2024.
//

import SwiftUI

internal struct Bookmark: View {
    
     internal let bookmark: Bool
    
    internal init(
        bookmark: Bool = false
    ) {
        self.bookmark = bookmark
    }
    
    internal var body: some View {
        if bookmark == false {
            Image("bookmark-active-icon")
        } else {
            Image("bookmark-active-icon")
        }
    }
}

#Preview {
    Bookmark()
}
