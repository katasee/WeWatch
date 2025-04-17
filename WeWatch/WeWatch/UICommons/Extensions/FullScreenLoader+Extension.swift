//
//  FullScreenLoader+Extension.swift
//  WeWatch
//
//  Created by Anton on 16/04/2025.
//

import SwiftUI

extension View {
    
    internal func fullScreenLoader(isLoading: Bool) -> some View {
        modifier(FullScreenLoader(isLoading: isLoading))
    }
}
