//
//  MeowleRatingPage.swift
//  meowleUITests
//
//  Created by a.gorshchak on 09.04.2024.
//

import XCTest

private extension String {
    static let ratingViewControllerScreenIdentifier = "ratingViewController"
}

final class MeowleRatingPage: BasePage {
    
    // MARK: - Elements
    
    private lazy var ratingScreen = app.otherElements[.ratingViewControllerScreenIdentifier]
    
    // MARK: - Asserts
    
    // Проверка, что экран "Рейтинг" открылся
    @discardableResult
    func checkThatRatingScreenIsOpened() -> MeowleRatingPage {
        XCTAssertTrue(ratingScreen.waitForExistence(timeout: .timeout))
        return self
    }
    
    // Проверка, что отображена страница с замоканными котиками
    @discardableResult
    func assertDisplayedMockedCat(name: String) -> MeowleRatingPage {
        XCTAssertTrue(app.staticTexts[name].waitForExistence(timeout: .timeout))
        return self
    }
}
