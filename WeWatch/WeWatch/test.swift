//
//  test.swift
//  WeWatch
//
//  Created by Anton on 24/12/2024.
//

import SwiftUI

struct test: View {
    var body: some View {
        ZStack {
            Color(.black)
                .ignoresSafeArea()
            VStack{
                HStack(spacing: 0) {
                    Text("splashView.title.first.part")
                        .foregroundColor(.whiteColor)
                    Text("splashView.title.second.part")
                        .foregroundColor(.fieryRed)
                }
                .font(.poppinsBold30px)
                Image.splashScreenIcon
                Group {
                    Text("splash.view.description.first.part.title")
                        .foregroundColor(.whiteColor)
                    + Text(". ")
                        .foregroundColor(.fieryRed)
                    + Text("splash.view.description.second.part.title")
                        .foregroundColor(.whiteColor)
                    + Text(". ")
                        .foregroundColor(.fieryRed)
                    + Text("splash.view.description.third.part.title")
                        .foregroundColor(.whiteColor)
                }
                .font(.poppinsBold24px)
            }
        }
    }
}

#Preview {
    test()
}
