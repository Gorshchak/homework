//
//  DispatchQueue+performOnMain.swift
//  meowle
//
//  Created by a.gorshchak on 19.02.2024.
//

import Foundation

extension DispatchQueue {

    static func performOnMain(_ block: @escaping () -> Void) {
        if Thread.isMainThread {
            block()
        } else {
            DispatchQueue.main.async(execute: block)
        }
    }
}
