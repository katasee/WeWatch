//
//  DetailsViewModel.swift
//  WeWatch
//
//  Created by Anton on 28/01/2025.
//

import Foundation

internal final class DetailsViewModel: ObservableObject {
    
    @Published internal var dataForDetailsView: MovieCardPreviewModel = .init(
        id: 1,
        title: "Hitman’s Wife’s Bodyguard",
        rating: 3.5,
        genres: "Horror",
        storyline: "The world's most lethal odd couple - bodyguard Michael Bryce and hitman Darius Kincaid - are back on another life-threatening mission. Still unlicensed and under scrutiny, Bryce is forced into action by Darius's even more volatile wife, the infamous international con artist Sonia Kincaid. As Bryce is driven over the edge by his two most dangerous protectees, the trio get in over their heads in a global plot and soon find that they are all that stand between Europe and a vengeful and powerful madman. Joining in the fun and deadly mayhem is Morgan Freeman as - well, you'll have to see.",
        image: URL(string: "https://m.media-amazon.com/images/M/MV5BZjFhZmU5NzUtZTg4Zi00ZjRjLWI0YmQtODk2MzI4YjNhYTdkXkEyXkFqcGc@._V1_FMjpg_UX1000_.jpg"
                  ))
}
