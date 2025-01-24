//
//  PillButton.swift
//  WeWatch
//
//  Created by Anton on 26/12/2024.
//

import SwiftUI

internal struct PillButton: View {

//    @State private var didTap: Bool
//    private let action: () -> Void
    private let title: String

    internal init(
        title: String
//        action: @escaping () -> Void,
//        didTap: Bool
    ) {
        self.title = title
//        self.action = action
//        self.didTap = didTap
    }

    internal var body: some View {
//        Button(action: {
////            action()
//            didTap = true
//        }) {
            Text(title)
                .foregroundColor(.whiteColor)
                .font(.poppinsRegular14px)
//        }
        .padding(.vertical, 2)
        .padding(.horizontal, 16)
//        .background(didTap ? Color.fieryRed : Color.darkGreyColor)
//        .clipShape(.capsule)
//        .controlSize(.mini)
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        PillButton(
            title: "Action"
//            action: {
//                // noop
//            },

        )
    }
}
