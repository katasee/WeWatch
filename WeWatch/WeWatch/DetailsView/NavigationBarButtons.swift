//
//  NavigationBarButtons.swift
//  WeWatch
//
//  Created by Anton on 30/01/2025.
//

import SwiftUI

internal struct NavigationBarButtons: View {
    
    @SwiftUI.Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>
    internal var movie: MovieCardPreviewModel
    private var action: (Int) -> Void
    init(
        movie: MovieCardPreviewModel,
        action: @escaping (Int) -> Void
    ) {
        self.movie = movie
        self.action = action
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().isTranslucent = true
        UINavigationBar.appearance().tintColor = .clear
        UINavigationBar.appearance().backgroundColor = .clear
    }
    
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
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            action(movie.id)
                        } label: {
                            Bookmark()
                        }
                    }
                }
        }
    }
}
