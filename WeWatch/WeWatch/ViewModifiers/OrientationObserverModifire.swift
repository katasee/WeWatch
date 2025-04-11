//
//  OrientationObserverModifire.swift
//  WeWatch
//
//  Created by Anton on 11/04/2025.
//

import SwiftUI

struct OrientationObserver: ViewModifier {
    
    let perform: (UIDeviceOrientation) -> Void
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                self.perform(UIDevice.current.orientation)
            }
            .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
                self.perform(UIDevice.current.orientation)
            }
    }
}

extension View {
    func onRotate(perform action: @escaping (UIDeviceOrientation) -> Void) -> some View {
        return modifier(OrientationObserver(perform: action))
    }
}
