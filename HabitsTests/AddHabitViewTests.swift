//
//  AddHabitViewTests.swift
//  HabitsUITests
//
//  Created by Christian Ost on 03.04.22.
//

import XCTest
@testable import Habits
import ViewInspector

private class MockAddHabitViewModel: AddHabitViewModel {
    var saveHabitCalled = false
    override func saveHabit() -> Bool {
        saveHabitCalled = true
        return true
    }
}

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
        let mockViewModel = MockAddHabitViewModel()
        var sut = AddHabitView()
        sut.viewModel = mockViewModel

        let nameInput = try sut.inspect().find(ViewType.TextField.self, where: { try $0.labelView().text().string() == "Name" })
        try nameInput.setInput("Test name")

        try sut.inspect().find(button: "Save").tap()
        
        XCTAssertEqual(mockViewModel.saveHabitCalled, true)
        // TODO: check for call to dismiss
    }
}
