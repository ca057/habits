//
//  Settings-ViewModel.swift
//  Habits
//
//  Created by Christian Ost on 30.03.23.
//

import Foundation
import UniformTypeIdentifiers
import SwiftUI

struct JSONFile: FileDocument {
    static var readableContentTypes = [UTType.json]
    static var writableContentTypes = [UTType.json]
    
    var data = Data()
    
    init(_ json: Data) {
        data = json
    }
    
    init(configuration: ReadConfiguration) throws {
        if let content = configuration.file.regularFileContents {
            data = content
        }
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let fileWrapper = FileWrapper(regularFileWithContents: data)
        fileWrapper.filename = "habits-export-\(Date().toString(format: .isoDate) ?? "?")"

        return fileWrapper
    }
}

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

        func getDataAsJsonFile() -> JSONFile {
            do {
                let export = try habitsStorage.exportAllHabits()
                
                return JSONFile(export)
            } catch {
                errorMessage = ErrorAlert(
                    showing: true,
                    title: "Export your data failed",
                    message: "Something went wrong during the export. Please try again." // TODO: original message
                )
                
                return JSONFile(Data())
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
