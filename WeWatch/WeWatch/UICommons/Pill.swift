//
//  Pill.swift
//  WeWatch
//
//  Created by Anton on 26/12/2024.
//

import SwiftUI

struct Pill: View {
    @State private var didTap: Bool = false
    private var pillTitle: String = .init()
    var body: some View {
        Button(action: {
            self.didTap = true
        }) {
            Text(pillTitle)
        }
        .padding(.top, 2)
        .padding(.bottom, 2)
        .padding(.leading, 16)
        .padding(.trailing,16)
        .background(didTap ? Color.fieryRed : Color.dakrGrey)
        .foregroundColor(.whiteColor)
        .font(.poppinsRegular14px)
        .clipShape(.capsule)
        .controlSize(.mini)
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea();
        Pill()
    }
}

