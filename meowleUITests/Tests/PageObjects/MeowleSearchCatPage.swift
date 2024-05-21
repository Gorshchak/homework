//
//  MeowleSearchCatPage.swift
//  meowleUITests
//
//  Created by a.gorshchak on 09.04.2024.
//

import XCTest

private extension String {
    static let nameOfCat = "Введите имя котика"
    static let identyfyerSearchButton = "searchCatButton"
    static let addButtonLabel = "Добавить"
    static let mainScreenIdentifier = "searchScreenViewController" 
    static let rating = "Рейтинг"
}

final class MeowleSearchCatPage: BasePage {
    
    // MARK: - Elements
    
    private lazy var searchField = app.textFields[.nameOfCat]
    private lazy var searchButtonWithIdentifyer = app.buttons[.identyfyerSearchButton]
    private lazy var addButton = app.buttons[.addButtonLabel]
    private lazy var mainScreenTitle = app.otherElements[.mainScreenIdentifier]
    private lazy var ratingButton = app.buttons[.rating]
    
    // MARK: - Actions
    
    //Тап по табе "Рейтинг"
    @discardableResult
    func tapRatingButton() -> MeowleRatingPage {
        ratingButton.tap()
        return MeowleRatingPage()
    }
    
    // Тап по кнопке "Добавить"
    @discardableResult
    func tapAddButton() -> MeowleSearchCatPage {
        addButton.tap()
        return self
    }
    
    // Тап по кнопке "Поиск"
    @discardableResult
    func tapSearchField() -> MeowleSearchCatPage {
        searchField.tap()
        return self
    }
    
    // Ввести текст в строку "Поиск"
    @discardableResult
    func typeTextTo(textField: String) -> MeowleSearchCatPage {
        searchField.typeText(textField)
        return self
    }
    
    // Тапнуть по кнопке c прописанным accessibilityIdentifyer
    @discardableResult
    func tapSearchButtonWithAccessibilityIdentifyer() -> MeowleSearchCatPage {
        searchButtonWithIdentifyer.tap()
        return self
    }
    
    // Тап по названию котика в поисковой выдаче
    @discardableResult
    func tapCat(name: String) -> MeowleSearchCatPage {
        app.staticTexts[name].tap()
        return self
    }
    
    // MARK: - Asserts
    
    // Проверка наличия имени котика
    @discardableResult
    func assertExistanceNameOf(cat: String) -> MeowleSearchCatPage {
        XCTAssertTrue(app.staticTexts[cat].waitForExistence(timeout: .timeout))
        return self
    }
    
    // Проверка, что экран "Поиск" открылся
    @discardableResult
    func checkThatSearchScreenIsOpened() -> MeowleSearchCatPage {
        XCTAssertTrue(mainScreenTitle.waitForExistence(timeout: .timeout))
        return self
    }
}
