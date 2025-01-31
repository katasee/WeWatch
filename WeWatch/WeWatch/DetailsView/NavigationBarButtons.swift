//
//  NavigationBarButtons.swift
//  WeWatch
//
//  Created by Anton on 30/01/2025.
//

import SwiftUI

internal struct NavigationBarButtons: View {
    
    @SwiftUI.Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>
    @State private var isActive: Bool = true
    
    internal var body: some View {
        HStack {
            Spacer()
                .navigationBarBackButtonHidden(true)
                .toolbar(content: {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            presentationMode.wrappedValue.dismiss()
                        } label: {
                            Image("back-icon")
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            isActive.toggle()
                        } label: {
                            if isActive == true {
                                Bookmark(isActive: true)
                            } else {
                                Bookmark(isActive: false)
                            }
                        }
                    }
                })
        }
    }
}
