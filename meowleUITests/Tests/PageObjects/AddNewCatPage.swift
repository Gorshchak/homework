//
//  AddANewCatPage.swift
//  meowleUITests
//
//  Created by a.gorshchak on 14.04.2024.
//

import XCTest

private extension String {
    static let addButtonLabel = "Добавить"
    static let nameOfCat = "Введите имя котика"
    static let successfulСompletion = "✅ Котик успешно добавлен"
    static let addAnewCatScreenIdentifier = "addAnewCatScreenViewController"
}

final class AddNewCatPage: BasePage {
    
    // MARK: - Elements
    
    private lazy var addCatButton = app.staticTexts[.addButtonLabel]
    private lazy var searchField = app.textFields[.nameOfCat]
    private lazy var catСompletion = app.staticTexts[.successfulСompletion]
    private lazy var coordinate = app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
    private lazy var addAnewCatScreen = app.otherElements[.addAnewCatScreenIdentifier]
    
    // MARK: - Actions
    
    // Тап по кнопке "Добавить" на экране добавления котика
    @discardableResult
    func tapAddCatButton() -> AddNewCatPage {
        addCatButton.tap()
        return self
    }
    
    // Тап по кнопке "Поиск" и ввод имя котика
    @discardableResult
    func enterCatName(textField: String) -> AddNewCatPage {
        searchField.tap()
        searchField.typeText(textField)
        return self
    }
    
    // Скрыть клавиатуру
    @discardableResult
    func hideKeyboard() -> AddNewCatPage {
        coordinate.tap()
        return self
    }

    // MARK: - Asserts
    
    // Проверка, что экран "Добавление котика" открылся
    @discardableResult
    func checkThatAnewCatScreenIsOpened() -> AddNewCatPage {
        XCTAssertTrue(addAnewCatScreen.waitForExistence(timeout: .timeout))
        return self
    }
    
    // Проверка отображения имени котика
    @discardableResult
    func assertExistanceNameOf(cat: String) -> AddNewCatPage {
        XCTAssertTrue(app.staticTexts[cat].waitForExistence(timeout: .timeout))
        return self
    }
    
    // Проверка успешного добалвения котика
    @discardableResult
    func assertSuccessfulСompletionOfCat() -> AddNewCatPage {
        XCTAssertTrue(catСompletion.waitForExistence(timeout: .timeout))
        return self
    }
}
