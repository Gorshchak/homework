//
//  MeowleRatingUITests.swift
//  meowleUITests
//
//  Created by a.gorshchak on 09.04.2024.
//

import Foundation
import XCTest
import Swifter

private extension String {
    static let mockedCat = "Кот №1"
    static let oneMoreMockedCat = "Кот №2"
}

final class MeowleRatingUITests: BasePage {
    
    // MARK: - Tests
    
    // Учимся мокать сущности. (Тест на отображение рейтинга):
    func testRatingPage() {
        
        
        setNetworkStub(for: "likes/cats/rating",
                       jsonFilename: "likes_cats_rating")
        
        openApp(isAuthorised: true)
        
        MeowleSearchCatPage()
            .checkThatSearchScreenIsOpened()
            .tapRatingButton()
        MeowleRatingPage()
            .checkThatRatingScreenIsOpened()
            .assertDisplayedMockedCat(name: .mockedCat)
            .assertDisplayedMockedCat(name: .oneMoreMockedCat)
    }
}
