//
//  FullScreenErrorPopUp.swift
//  WeWatch
//
//  Created by Anton on 16/04/2025.
//

import SwiftUI

extension View {
    
    func fullScreenErrorPopUp(error: Binding<(any Error)?>, onRetry:  @escaping () -> Void) -> some View {
        modifier(ErrorPopup(error: error, onRetry: onRetry))
    }
}
