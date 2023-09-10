//
//  Settings-ViewModel.swift
//  Habits
//
//  Created by Christian Ost on 30.03.23.
//

import SwiftUI

struct ErrorAlert {
    var showing = false
    var title = ""
    var message = ""
}

extension Settings {
    @MainActor final class ViewModel: ObservableObject {
        @Published var errorMessage = ErrorAlert()
        @Published var showingExporter = false
        @Published var showingImporter = false
        
        private let habitsStorage = HabitsStorage.shared

        func getDataAsJsonFile() -> HabitsStorage.JSONFile? {
            do {
                let export = try habitsStorage.exportAllHabits()
                
                return export
            } catch {
                errorMessage = ErrorAlert(
                    showing: true,
                    title: "Export your data failed",
                    message: "Something went wrong during the export. Please try again." // TODO: original message
                )
                
                return nil
            }
        }
        
        func importDataFromJsonFileUrl(_ urls: [URL]) {
            if urls.count > 1 {
                errorMessage = ErrorAlert(
                    showing: true,
                    title: "Importing your data failed",
                    message: "You can only import one file at once. Please try again."
                )
                return
            }
            
            guard let url = urls.first else {
                errorMessage = ErrorAlert(
                    showing: true,
                    title: "Importing your data failed",
                    message: "Something went wrong retrieving the file location. Please try again."
                )
                return
            }
            
            do {
                try habitsStorage.importDataFromUrl(url)
            } catch {
                print("error during import \(error)")
                errorMessage = ErrorAlert(
                    showing: true,
                    title: "Importing your data failed",
                    message: "The data in your export couldn’t be read. Check if it’s a valid export and try again."
                )
            }
        }
    }
}
