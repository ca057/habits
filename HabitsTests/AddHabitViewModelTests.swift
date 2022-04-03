//
//  AddHabitViewModelTests.swift
//  HabitsTests
//
//  Created by Christian Ost on 03.04.22.
//

import Foundation
@testable import Habits
import XCTest

class AddHabitViewModelTests: XCTestCase {
    override func setUpWithError() throws {
        
    }
    
    override func tearDownWithError() throws {
        
    }
    
    // MARK: - Tests
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
}
