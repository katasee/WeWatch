//
//  ViewDidLoad+Extension.swift
//  WeWatch
//
//  Created by Anton on 16/04/2025.
//

import SwiftUI

extension View {
    
    internal func onLoad(perform action: (() -> Void)? = nil) -> some View {
        modifier(ViewDidLoadModifire(perform: action))
    }
}
