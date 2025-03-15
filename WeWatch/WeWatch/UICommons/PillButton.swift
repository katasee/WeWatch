//
//  PillButton.swift
//  WeWatch
//
//  Created by Anton on 26/12/2024.
//

import SwiftUI

internal struct PillButton: View {
    
    private var isActive: Bool
    private let title: String
    private var action: () -> Void
    
    internal init(
        isActive: Bool,
        title: String,
        action: @escaping () -> Void
    ) {
        self.isActive = isActive
        self.title = title
        self.action = action
    }
    
    internal var body: some View {
        Button(action: {
            action()
        }) {
            Text(title)
                .foregroundColor(.whiteColor)
                .font(.poppinsRegular14px)
                .padding(.vertical, 2)
                .padding(.horizontal, 16)
                .background(isActive ? Color.fieryRed : Color.darkGreyColor)
                .clipShape(.capsule)
                .controlSize(.mini)
        }
    }
}
