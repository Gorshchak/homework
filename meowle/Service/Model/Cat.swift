//
//  Cat.swift
//  meowle
//
//  Created by a.gorshchak on 03.02.2024.
//

import Foundation

struct Cat: Codable {
    let id: Int
    let name: String
    let description: String?
    let gender: Gender
    let likes: Int
    let dislikes: Int
}

enum Gender: String, Codable, CaseIterable {
    case female = "female"
    case male = "male"
    case unisex = "unisex"
    
    var icon: String {
        switch self {
        case .female:
            return "♀"
        case .male:
            return "♂"
        case .unisex:
            return "♀♂"
        }
    }
}
