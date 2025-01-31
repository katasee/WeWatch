//
//  ExpandableTextView.swift
//  WeWatch
//
//  Created by Anton on 29/01/2025.
//

import SwiftUI

internal struct ExpandableTextView: View {
    
    @State private var fullText: Bool = false
    @State private var clipped: Bool = false
    
    internal let lineLimit: Int
    internal let movie: MovieCardPreviewModel
    
    internal init(
        lineLimit: Int,
        movie: MovieCardPreviewModel
    ) {
        self.lineLimit = lineLimit
        self.movie = movie
    }
    
    private var moreLessText: LocalizedStringKey {
        if !clipped {
            ""
        } else {
            self.fullText ? "read.less.button" : "read.more.button"
        }
    }
    
    internal var body: some View {
        VStack(alignment: .leading) {
            text
                .background(
                    verificateIfTextClipped
                )
            if clipped {
                buttonMoreLess
            }
        }
    }
    
    private var text: some View {
        Text(movie.storyline)
            .lineLimit(fullText ? nil : lineLimit)
    }
    
    private var verificateIfTextClipped: some View {
        Text(movie.storyline).lineLimit(lineLimit)
            .background(GeometryReader { visibleTextGeometry in
                ZStack {
                    Text(movie.storyline)
                        .background(GeometryReader { fullTextGeometry in
                            Color.clear.onAppear {
                                self.clipped = fullTextGeometry.size.height > visibleTextGeometry.size.height
                            }
                        })
                }
                .frame(height: .greatestFiniteMagnitude)
            })
            .hidden()
    }
    
    private var buttonMoreLess: some View {
        Button {
            withAnimation {
                fullText.toggle()
            }
        } label: {
            Text(moreLessText)
                .foregroundColor(Color.fieryRed)
                .font(.poppinsRegular16px)
        }
    }
}
