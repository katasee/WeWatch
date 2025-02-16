//
//  BackButton.swift
//  WeWatch
//
//  Created by Anton on 16/02/2025.
//

import SwiftUI

internal struct BackButton: View {
    @SwiftUI.Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>

    init() {
            UINavigationBar.appearance().setBackgroundImage(UIImage(), for: UIBarMetrics.default)
            UINavigationBar.appearance().shadowImage = UIImage()
            UINavigationBar.appearance().isTranslucent = true
            UINavigationBar.appearance().tintColor = .clear
            UINavigationBar.appearance().backgroundColor = .clear
        }
    var body: some View {
        HStack {
            Spacer()
                .navigationBarBackButtonHidden(true)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            presentationMode.wrappedValue.dismiss()
                        } label: {
                            Image("back-icon")
                        }
                    }
                    ToolbarItem(placement: .navigationBarLeading) {
                        title
                    }
                }
        }
    }
    
    private var title: some View {
        Text("Discover")
            .foregroundColor(.whiteColor)
            .font(.poppinsBold30px)
        + Text(". ")
            .foregroundColor(.fieryRed)
            .font(.poppinsBold30px)
    }
}

