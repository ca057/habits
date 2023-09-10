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

struct HabitsExportItemEntry: Codable {
    let date: Date
}

struct HabitsExportItem: Codable {
    let id: UUID?
    let name: String?
    let createdAt: Date?
    let colour: String?
    let entries: [HabitsExportItemEntry]
}

struct HabitsExport: Codable {
    let appVersion: String
    let exportDate: Date
    let habits: [HabitsExportItem]
}

struct ErrorAlert {
    var showing = false
    var title = ""
    var message = ""
}

enum SettingsError: Error {
    case importFailed
}

extension Settings {
    @MainActor final class ViewModel: ObservableObject {
        @Published var errorMessage = ErrorAlert()
        @Published var showingExporter = false
        @Published var showingImporter = false
        
        private let habitsStorage = HabitsStorage.shared

        func getDataAsJsonFile() -> JSONFile {
            // TODO: do I need to make this async? for sure with a cool animation
            
            var habits: [HabitsExportItem] = []
            habitsStorage.habits.forEach({ habit in
                var entries: [HabitsExportItemEntry] = []
                habit.entry?.array.forEach({
                    guard let entryDate = ($0 as? Entry)?.date else { return }
                    
                    entries.append(HabitsExportItemEntry(date: entryDate))
                })
                
                habits.append(HabitsExportItem(
                    id: habit.id,
                    name: habit.name,
                    createdAt: habit.createdAt,
                    colour: habit.colour,
                    entries: entries
                ))
            })
            
            let export = HabitsExport(
                appVersion: Bundle.main.versionAndBuildNumber,
                exportDate: Date(),
                habits: habits
            )
            
            let jsonEncoder = JSONEncoder()
            jsonEncoder.dateEncodingStrategy = .iso8601
            jsonEncoder.outputFormatting = .prettyPrinted
            
            do {
                let habitsAsJson = try jsonEncoder.encode(export)
                
                return JSONFile(habitsAsJson)
            } catch {
                print("something failed \(error)")
                
                return JSONFile(Data())
            }
        }
        
        func getDataAsJson() -> String {
            // TODO: do I need to make this async? for sure with a cool animation
            
            var habits: [HabitsExportItem] = []
            habitsStorage.habits.forEach({ habit in
                var entries: [HabitsExportItemEntry] = []
                habit.entry?.array.forEach({
                    guard let entryDate = ($0 as? Entry)?.date else { return }
                    
                    entries.append(HabitsExportItemEntry(date: entryDate))
                })
                                
                habits.append(HabitsExportItem(
                    id: habit.id,
                    name: habit.name,
                    createdAt: habit.createdAt,
                    colour: habit.colour,
                    entries: entries
                ))
            })
            
            let export = HabitsExport(
                appVersion: Bundle.main.versionAndBuildNumber,
                exportDate: Date(),
                habits: habits
            )
            
            let jsonEncoder = JSONEncoder()
            jsonEncoder.dateEncodingStrategy = .iso8601
            jsonEncoder.outputFormatting = .prettyPrinted
            
            do {
                let habitsAsJson = try jsonEncoder.encode(export)

                return String(data: habitsAsJson, encoding: .utf8) ?? "export failed: N/A"
            } catch {
                print("something failed \(error)")
                
                return "export failed: \(error.localizedDescription)"
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
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            do {
                guard let data = try String(contentsOf: url).data(using: .utf8) else {
                    throw SettingsError.importFailed
                }
                
                let backup = try decoder.decode(HabitsExport.self, from:  data)
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
