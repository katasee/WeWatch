//
//  ErrorPopup.swift
//  WeWatch
//
//  Created by Anton on 31/03/2025.
//

import SwiftUI

struct ErrorPopup: ViewModifier {
    
    @Binding private var error: (any Error)?
    private let onRetry: () -> Void
    
    init(
        error: Binding<(any Error)?>,
        onRetry: @escaping () -> Void
    ){
        self._error = error
        self.onRetry = onRetry
    }
    
    internal func body(content: Content) -> some View {
        content
            .blur(radius: (error != nil) ? 10 : 0)
            .allowsHitTesting((error != nil) ? false : true)
            .overlay(alignment: .center) {
                if let error = error {
                    VStack(alignment: .center) {
                        Image(systemName: "exclamationmark.circle")
                            .foregroundColor(.red)
                        Text("custom.error.message")
                            .bold()
                        Text(error.localizedDescription)
                            .multilineTextAlignment(.center)
                        Button() {
                            self.error = nil
                        } label: {
                            Text("cancel.button")
                                .frame(maxWidth: .infinity, maxHeight: 44)
                                .background(RoundedRectangle(cornerRadius: 12.0).fill(Color.lightGrey))
                        }
                        .padding(.horizontal, 16)
                        Button() {
                            self.error = nil
                            onRetry()
                        } label: {
                            Text("Try.again.button")
                                .frame(maxWidth: .infinity, maxHeight: 44)
                                .background(RoundedRectangle(cornerRadius: 12.0).fill(Color.fieryRed))
                        }
                        .padding(.horizontal, 16)
                    }
                    .frame(maxWidth: .infinity, maxHeight: 255)
                    .foregroundColor(.whiteColor)
                    .font(.poppinsRegular16px)
                    .background(RoundedRectangle(cornerRadius: 12.0).fill(Color.darkGreyColor))
                    .padding(.horizontal, 24)
                    if error == nil {
                        content
                    }
                }
            }
    }
}
extension View {
    func fullScreenErrorPopUp(error: Binding<(any Error)?>, onRetry:  @escaping () -> Void) -> some View {
        modifier(ErrorPopup(error: error, onRetry: onRetry))
    }
}

