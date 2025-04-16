//
//  OrientationObserver + extension.swift
//  WeWatch
//
//  Created by Anton on 16/04/2025.
//

import SwiftUI

extension View {
    
    internal func onRotate(perform action: @escaping (UIDeviceOrientation) -> Void) -> some View {
        return modifier(OrientationObserver(perform: action))
    }
}
