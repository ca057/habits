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
    func testAddHabitButton_showsSaveWhenFormFilledOut() throws {
        let sut = AddHabitView()
        
        // we have a cancel button initially
        _ = try sut.inspect().find(button: "Cancel")
        
        // input name
        let nameInput = try sut.inspect().find(ViewType.TextField.self, where: { try $0.labelView().text().string() == "Name" })
        try nameInput.setInput("Test name")

        // we expect to have a save button
        _ = try sut.inspect().find(button: "Save")
    }
}
