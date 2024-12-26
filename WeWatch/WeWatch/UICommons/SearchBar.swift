//
//  SearchBar.swift
//  WeWatch
//
//  Created by Anton on 25/12/2024.
//

import SwiftUI

struct SearchBar: View {
    @State private var searchText: String = ""
    var body: some View {
        HStack {
            Image("search-default-icon")
                .resizable()
                .frame(width: 20.0, height: 20.0)
            ZStack(alignment: .leading) {
                if searchText .isEmpty {
                    Text("Search")
                        .foregroundColor(.lightGreyColor)
                }
                TextField("", text: $searchText)
            }
        }
        .padding()
        .foregroundColor(.whiteColor)
        .background(RoundedRectangle(cornerRadius: 10.0).fill(Color.darkGreyColor))
        .font(.poppinsRegular16px)
        .cornerRadius(10)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

#Preview {
    SearchBar()
}
