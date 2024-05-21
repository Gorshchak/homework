//
//  FavCache.swift
//  meowle
//
//  Created by a.gorshchak on 18.03.2024.
//

import Foundation

final class FavCache {
    
    // Private
    private static var favCats: [Cat] = {
        if let url = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first?.appendingPathComponent("favCats.json"),
           let data = try? Data(contentsOf: url) {
            return (try? JSONDecoder().decode([Cat].self, from: data)) ?? []
        }
        return []
    }() {
        didSet {
            if let url = FileManager.default.urls(
                for: .documentDirectory,
                in: .userDomainMask
            ).first?.appendingPathComponent("favCats.json"),
               let data = try? JSONEncoder().encode(favCats) {
                try? data.write(to: url)
            }
        }
    }
    
    func fetchAll() -> [Cat] {
        return Self.favCats
    }
    
    func add(cat: Cat) {
        if !contains(catId: cat.id) {
            Self.favCats.append(cat)
        } else {
            remove(catId: cat.id)
            add(cat: cat)
        }
    }
    
    func contains(catId: Int) -> Bool {
        return Self.favCats.contains(where: { $0.id == catId })
    }
    
    func remove(catId: Int) {
        Self.favCats.removeAll { $0.id == catId }
    }
}
