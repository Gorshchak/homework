//
//  MeowleAuthPage.swift
//  MeowleUITests
//
//  Created by a.gorshchak on 09.04.2024.
//

import XCTest

private extension String {
    static let authorizationTextField = "Введите своё имя"
    static let authEnterButton = "Войти"
}

final class MeowleAuthPage: BasePage {
    
    // MARK: - Elements
    
    private lazy var fieldText = app.textFields[.authorizationTextField]
    private lazy var enterButton = app.buttons[.authEnterButton]
    
    // MARK: - Actions
    
    // Ввести текст в поле "Введите свое имя"
    @discardableResult
    func typeTextTo(textField: String) -> MeowleAuthPage {
        fieldText.typeText(textField)
        return self
    }
    
    // Тап по полю "Введите свое имя"
    @discardableResult
    func taptextField() -> MeowleAuthPage {
        fieldText.tap()
        return self
    }
    
    // Тап по кнопке "Войти"
    @discardableResult
    func tapEnterButton() -> MeowleAuthPage {
        enterButton.tap()
        return self
    }
}
