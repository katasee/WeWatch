//
//  Bookmark.swift
//  WeWatch
//
//  Created by Anton on 27/12/2024.
//

import SwiftUI

internal struct Bookmark: View {
    
    internal let isActive: Bool
    
    internal init(
        isActive: Bool = false
    ) {
        self.isActive = isActive
    }
    
    internal var body: some View {
        if isActive == false {
            Image("bookmark-inactive-icon")
        } else {
            Image("bookmark-active-icon")
        }
    }
}
