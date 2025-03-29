//
//  NavigationBarButtons.swift
//  WeWatch
//
//  Created by Anton on 30/01/2025.
//

import SwiftUI

internal struct NavigationBarButtons: View {
    
    @SwiftUI.Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>
    private let refreshBookmark: @MainActor(Movie) async -> Void
    internal var movie: Movie
    private var didTap: @MainActor (Bool) -> Void
    
    init(
        refreshBookmark: @escaping @MainActor(Movie) async -> Void,
        movie: Movie,
        didTap: @escaping(Bool) -> Void
    ) {
        self.refreshBookmark = refreshBookmark
        self.movie = movie
        self.didTap = didTap
        
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
                            let movieSelected = !movie.isBookmarked
                            didTap(movieSelected)
                            Task {
                                await refreshBookmark(movie)
                            }
                        } label: {
                            Bookmark(isActive: movie.isBookmarked)
                        }
                    }
                }
        }
    }
}
