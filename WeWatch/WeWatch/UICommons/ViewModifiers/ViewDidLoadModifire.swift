//
//  ViewDidLoadModifier.swift
//  WeWatch
//
//  Created by Anton on 07/04/2025.
//

import SwiftUI

internal struct ViewDidLoadModifire: ViewModifier {
    
    @State private var didLoad = false
    private let action: (() -> Void)?
    
    init(perform action: (() -> Void)? = nil) {
        self.action = action
    }
    
    internal func body(content: Content) -> some View {
        content.onAppear {
            if didLoad == false {
                didLoad = true
                action?()
            }
        }
    }
}
