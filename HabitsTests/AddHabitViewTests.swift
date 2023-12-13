//
//  AddHabitViewTests.swift
//  HabitsUITests
//
//  Created by Christian Ost on 03.04.22.
//

import XCTest
@testable import Habits
import ViewInspector

extension AddHabitView: Inspectable {}

class AddHabitViewTests: XCTestCase {

    override func setUpWithError() throws {}

    override func tearDownWithError() throws {}

    // #MARK: - UI test
    func testCancelButton_exists() throws {
        let sut = AddHabitView()
        
        _ = try sut.inspect().find(button: "Cancel")
    }

    func testCancelButton_dismissesView() throws {
        let sut = AddHabitView()
        
        _ = try sut.inspect().find(button: "Cancel")
        
        // TODO: check for call to dismiss
    }
    
    func testSaveButton_exists() throws {
        let sut = AddHabitView()
        
        _ = try sut.inspect().find(button: "Save")
    }
    
    func testSaveButton_whenFormIsFilledOut() throws {
        var sut = AddHabitView()

        let nameInput = try sut.inspect().find(ViewType.TextField.self, where: { try $0.labelView().text().string() == "I want to track..." })
        try nameInput.setInput("Test name")

//        try sut.inspect().find(button: "Save").tap()

        // TODO: check for modelContext to be called
    }
}
