//
//  RatingResponse.swift
//  meowle
//
//  Created by a.gorshchak on 03.02.2024.
//

import Foundation

struct RatingResponse: Codable {
    let likes: [LikedCats]
    let dislikes: [DislikedCats]
}

struct DislikedCats: Codable {
    let id: Int
    let name: String
    let dislikes: Int
}

struct LikedCats: Codable {
    let id: Int
    let name: String
    let likes: Int
}
