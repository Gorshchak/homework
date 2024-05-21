//
//  AddNewCatUITests.swift
//  meowleUITests
//
//  Created by a.gorshchak on 13.04.2024.
//

import XCTest

private extension String {
    static let nameOfCat = "Батон"
}

final class AddNewCatUITests: BasePage {
    
    // MARK: - Tests
    
    // Добавление нового котика
    func testAddCat() {
        
        openApp(isAuthorised: true)
        
        MeowleSearchCatPage()
            .checkThatSearchScreenIsOpened()
            .tapAddButton()
        AddNewCatPage()
            .checkThatAnewCatScreenIsOpened()
            .enterCatName(textField: .nameOfCat)
            .hideKeyboard()
            .tapAddCatButton()
            .assertSuccessfulСompletionOfCat()
    }
}
