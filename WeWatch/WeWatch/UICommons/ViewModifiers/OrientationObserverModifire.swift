//
//  OrientationObserverModifire.swift
//  WeWatch
//
//  Created by Anton on 11/04/2025.
//

import SwiftUI

internal struct OrientationObserver: ViewModifier {
    
    internal let perform: (UIDeviceOrientation) -> Void
    
    internal func body(content: Content) -> some View {
        content
            .onAppear {
                self.perform(UIDevice.current.orientation)
            }
            .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
                self.perform(UIDevice.current.orientation)
            }
    }
}
