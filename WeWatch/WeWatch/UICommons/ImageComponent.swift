//
//  ImageComponent.swift
//  WeWatch
//
//  Created by Anton on 29/12/2024.
//

import SwiftUI

internal struct ImageComponent: View {
    
    private var image: Image?
    
    internal init(image: Image?) {
        self.image = image
    }
    
    internal var body: some View {
        if let image = image {
            image
                .resizable()
        } else {
            ImagePlaceholder()
        }
    }
}

#Preview {
    ImageComponent(
        image: nil
    )
}
