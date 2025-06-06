//
//  SearchBar.swift
//  WeWatch
//
//  Created by Anton on 25/12/2024.
//

import SwiftUI

internal struct SearchBar: View {
    
    @Binding private var searchText: String
    
    internal init(searchText: Binding<String>) {
        self._searchText = searchText
    }
    
    internal var body: some View {
        HStack(spacing: 16) {
            searchIcon
            ZStack(alignment: .leading) {
                if searchText .isEmpty {
                    Text("search.bar.promt.title")
                }
                textField
            }
            .frame(maxWidth: .infinity, maxHeight: 38)
        }
        .foregroundColor(searchText.count > 0 ? .whiteColor : .lightGreyColor)
        .background(RoundedRectangle(cornerRadius: 10.0).fill(Color.darkGreyColor))
        .font(.poppinsRegular16px)
        .cornerRadius(10)
    }
    
    internal var searchIcon: some View {
        Image("search-inactive-icon")
            .renderingMode(.template)
            .resizable()
            .frame(width: 15.0, height: 15.0)
            .padding(.leading, 16)
    }
    
    private var textField: some View {
        TextField("", text: $searchText)
            .foregroundColor(Color.whiteColor)
            .overlay(
                Image(systemName: "xmark.circle.fill")
                    .padding(16)
                    .offset(x: 10)
                    .foregroundColor(Color.lightGreyColor)
                    .opacity(searchText.isEmpty ? 0.0 : 1.0)
                    .onTapGesture {
                        searchText = ""
                    }
                ,alignment: .trailing
            )
    }
}
