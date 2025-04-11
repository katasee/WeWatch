//
//  BackButton.swift
//  WeWatch
//
//  Created by Anton on 16/02/2025.
//

import SwiftUI

internal struct BackButton: View {
    
    @SwiftUI.Environment(\.presentationMode)
    private var presentationMode: Binding<PresentationMode>
    
    internal var body: some View {
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
                .toolbarBackground(Color.black)
        }
    }
    
    private var title: some View {
        Text("Discover")
            .foregroundColor(.whiteColor)
            .font(.poppinsBold24px)
        + Text(". ")
            .foregroundColor(.fieryRed)
            .font(.poppinsBold24px)
    }
}

