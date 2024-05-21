//
//  CatsSearchResult.swift
//  meowle
//
//  Created by a.gorshchak on 03.02.2024.
//

import Foundation

struct CatsSearchResponce: Codable {
    let groups: [CatsGroup]
}

struct CatsGroup: Codable {
    let title: String
    let cats: [Cat]
}
