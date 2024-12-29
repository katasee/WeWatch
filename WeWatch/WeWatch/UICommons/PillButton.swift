//
//  PillButton.swift
//  WeWatch
//
//  Created by Anton on 26/12/2024.
//

import SwiftUI

let noop: () -> Void = {}

internal struct PillButton: View {
    
    @State private var didTap: Bool = false
    private let action: () -> Void
    private let title: String
    
    internal init(
        title: String,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.action = action
    }
    
    internal var body: some View {
        Button(action: {
            action()
            didTap = true
        }) {
            Text(title)
                .foregroundColor(.whiteColor)
                .font(.poppinsRegular14px)
        }
        .padding(.vertical, 2)
        .padding(.horizontal, 16)
        .background(didTap ? Color.fieryRed : Color.darkGreyColor)
        .clipShape(.capsule)
        .controlSize(.mini)
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        PillButton(
            title: "Action",
            action: noop)
    }
}

