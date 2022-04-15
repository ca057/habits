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
    
    func testSaveButton_exists() throws {
        let sut = AddHabitView()
        
        _ = try sut.inspect().find(button: "Save")
    }
    
    func testSaveButton_callsViewModel() throws {
        let sut = AddHabitView()

        let nameInput = try sut.inspect().find(ViewType.TextField.self, where: { try $0.labelView().text().string() == "Name" })
        try nameInput.setInput("Test name")

        try sut.inspect().find(button: "Save").tap()
        
        // TODO: expect viewmodel to be called
    }
}
