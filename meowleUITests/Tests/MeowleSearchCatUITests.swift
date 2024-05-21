//
//  MeowleSearchCatUITests.swift
//  meowleUITests
//
//  Created by a.gorshchak on 09.04.2024.
//

import XCTest

private extension String {
    static let catBaton = "Батон"
    static let nameOfCatAccordingSearchResults = "Батон ♂"
}

final class MeowleSearchCatUITests: BasePage {
    
    // MARK: - Tests
    
    // Учимся прописывать (accessibilityIdentifyer) элементу. (Поиск котика):
    func testSearchOfAcat() {
        
        openApp(isAuthorised: true)
        
        MeowleSearchCatPage()
            .checkThatSearchScreenIsOpened()
            .tapSearchField()
            .typeTextTo(textField: .catBaton)
            .tapSearchButtonWithAccessibilityIdentifyer()
            .assertExistanceNameOf(cat: .catBaton)
            .tapCat(name: .catBaton)
            .assertExistanceNameOf(cat: .nameOfCatAccordingSearchResults)
    }
}
