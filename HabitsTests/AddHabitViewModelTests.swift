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

    func addHabit(name: String) {
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
        let viewModel = AddHabitViewModel()
        
        viewModel.name = "test"
        let success = viewModel.saveHabit()
        
        XCTAssertEqual(success, true)
    }

    func testSaveHabit_whenIsNotValid() {
        let viewModel = AddHabitViewModel()
        
        viewModel.name = ""
        let success = viewModel.saveHabit()
        
        XCTAssertEqual(success, false)
    }
}
