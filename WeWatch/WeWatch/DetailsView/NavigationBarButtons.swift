//
//  NavigationBarButtons.swift
//  WeWatch
//
//  Created by Anton on 30/01/2025.
//

import SwiftUI

internal struct NavigationBarButtons: View {
    
    @SwiftUI.Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>
    @State private var isActive: Bool
    internal var movie: Movie
    private var action: (String) -> Void
    private var didTap: @MainActor (Bool) -> Void
    private let bookmarkAddAction: @MainActor (Movie) async -> Void
    private let bookmarkRemoveAction: @MainActor (Movie) async -> Void
    
    init(
        isActive: Bool,
        movie: Movie,
        action: @escaping(String) -> Void,
        didTap: @escaping(Bool) -> Void,
        bookmarkAddAction: @escaping @MainActor (Movie) async -> Void,
        bookmarkRemoveAction: @escaping @MainActor (Movie) async -> Void
        
    ) {
        self.isActive = isActive
        self.movie = movie
        self.action = action
        self.didTap = didTap
        self.bookmarkAddAction = bookmarkAddAction
        self.bookmarkRemoveAction = bookmarkRemoveAction
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
                            isActive.toggle()
                            didTap(isActive)
                            if isActive == true {
                                Task {
                                    await bookmarkAddAction(movie)
                                }
                            } else {
                                Task {
                                    await bookmarkRemoveAction(movie)
                                }
                            }
                        } label: {
                            if isActive == true {
                                Bookmark(isActive: true)
                            } else {
                                Bookmark(isActive: false)
                            }
                        }
                    }
                }
        }
    }
}
