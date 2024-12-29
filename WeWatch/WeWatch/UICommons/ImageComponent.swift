//
//  ImageComponent.swift
//  WeWatch
//
//  Created by Anton on 29/12/2024.
//

import SwiftUI

struct ImageComponent: View {
    
    private var image: Image?
    internal init(image: Image?) {
        self.image = image
    }
    var body: some View {
        if let image = image {
            image
                .resizable()
        } else {
            LargeCover()
        }
    }
}

#Preview {
    ImageComponent(
        image: nil
    )
}
