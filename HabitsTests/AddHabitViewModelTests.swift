//
//  AddHabitViewModelTests.swift
//  HabitsTests
//
//  Created by Christian Ost on 03.04.22.
//

import Foundation
@testable import Habits
import XCTest

private class MockDataController: DataController {
    var addHabitCalledWith = [String: String]()

    override func addHabit(name: String) {
        addHabitCalledWith = [
            "name": name
        ]
    }
}

class AddHabitViewModelTests: XCTestCase {
    override func setUpWithError() throws {
        
    }
    
    override func tearDownWithError() throws {
        
    }
    
    // MARK: - Tests for properties
    func testIsValid_whenTextIsNotEmpty() {
        let viewModel = AddHabitViewModel()
        
        viewModel.name = "test"
        
        XCTAssertEqual(viewModel.isValid, true)
    }

    func testIsValid_whenTextIsEmpty() {
        let viewModel = AddHabitViewModel()
        
        viewModel.name = ""
        
        XCTAssertEqual(viewModel.isValid, false)
    }
    
    // MARK: - Tests for actions
    func testSaveHabit_whenIsValid() {
        let mockDataController = MockDataController()
        let viewModel = AddHabitViewModel(dataController: mockDataController)
        
        viewModel.name = "test"
        let success = viewModel.saveHabit()
        
        XCTAssertEqual(mockDataController.addHabitCalledWith["name"], viewModel.name)
        XCTAssertEqual(success, true)
    }

    func testSaveHabit_whenIsNotValid() {
        let mockDataController = MockDataController()
        let viewModel = AddHabitViewModel(dataController: mockDataController)
        
        viewModel.name = ""
        let success = viewModel.saveHabit()
        
        XCTAssertEqual(mockDataController.addHabitCalledWith.isEmpty, true)
        XCTAssertEqual(success, false)
    }
}
